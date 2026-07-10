<?php
/**
 * HTTPS reverse proxy for local Yii dev server (PHP built-in server is HTTP-only).
 */

declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "Run from CLI only.\n");
    exit(1);
}

if (!extension_loaded('openssl')) {
    fwrite(STDERR, "PHP OpenSSL extension is required.\n");
    exit(1);
}

$options = getopt('', ['listen:', 'port:', 'backend:', 'cert:', 'key:']);
$listen = (string) ($options['listen'] ?? '0.0.0.0');
$port = (int) ($options['port'] ?? 8888);
$backend = (string) ($options['backend'] ?? '127.0.0.1:8889');
$cert = (string) ($options['cert'] ?? __DIR__ . '/certs/dev-cert.pem');
$key = (string) ($options['key'] ?? __DIR__ . '/certs/dev-key.pem');

if (!is_file($cert) || !is_file($key)) {
    fwrite(STDERR, "Certificate not found. Run scripts/generate-dev-cert.ps1 first.\n");
    exit(1);
}

$backendParts = explode(':', $backend, 2);
if (count($backendParts) !== 2) {
    fwrite(STDERR, "Invalid backend address: {$backend}\n");
    exit(1);
}
[$backendHost, $backendPortRaw] = $backendParts;
$backendPort = (int) $backendPortRaw;
if ($backendPort <= 0) {
    fwrite(STDERR, "Invalid backend port: {$backendPortRaw}\n");
    exit(1);
}

$context = stream_context_create([
    'ssl' => [
        'local_cert' => $cert,
        'local_pk' => $key,
        'verify_peer' => false,
        'verify_peer_name' => false,
        'allow_self_signed' => true,
    ],
]);

$address = "ssl://{$listen}:{$port}";
$server = @stream_socket_server(
    $address,
    $errno,
    $errstr,
    STREAM_SERVER_BIND | STREAM_SERVER_LISTEN,
    $context
);
if ($server === false) {
    fwrite(STDERR, "Cannot bind {$address}: {$errstr} ({$errno})\n");
    exit(1);
}

fwrite(STDOUT, "HTTPS proxy listening on {$listen}:{$port} -> http://{$backendHost}:{$backendPort}\n");
fwrite(STDOUT, "Use https:// on port {$port}.\n");
fwrite(STDOUT, "Press Ctrl+C to stop.\n");

while (true) {
    $client = @stream_socket_accept($server, -1);
    if ($client === false) {
        continue;
    }
    stream_set_timeout($client, 60);
    handleClient($client, $backendHost, $backendPort);
    fclose($client);
}

/**
 * @param resource $client
 */
function handleClient($client, string $backendHost, int $backendPort): void
{
    $request = readHttpRequest($client);
    if ($request === null) {
        fwrite($client, "HTTP/1.1 400 Bad Request\r\nContent-Type: text/plain; charset=UTF-8\r\nConnection: close\r\n\r\nEmpty request\r\n");
        return;
    }

    $clientIp = peerIp($client);
    $payload = addProxyHeaders($request['raw'], $clientIp);

    $backend = @fsockopen($backendHost, $backendPort, $errno, $errstr, 15);
    if ($backend === false) {
        fwrite($client, "HTTP/1.1 502 Bad Gateway\r\nContent-Type: text/plain; charset=UTF-8\r\nConnection: close\r\n\r\nBackend unavailable: {$errstr}\n");
        return;
    }

    stream_set_timeout($backend, 60);
    fwrite($backend, $payload);
    $response = stream_get_contents($backend);
    if ($response !== false && $response !== '') {
        fwrite($client, $response);
    }
    fclose($backend);
}

/**
 * @param resource $stream
 * @return array{raw: string}|null
 */
function readHttpRequest($stream): ?array
{
    $raw = '';
    $deadline = microtime(true) + 15.0;

    while (microtime(true) < $deadline && !feof($stream)) {
        $chunk = fread($stream, 8192);
        if ($chunk === false) {
            break;
        }
        if ($chunk === '') {
            usleep(10000);
            continue;
        }
        $raw .= $chunk;
        if (strpos($raw, "\r\n\r\n") !== false) {
            break;
        }
    }

    if ($raw === '' || strpos($raw, "\r\n\r\n") === false) {
        return null;
    }

    [$head, $body] = explode("\r\n\r\n", $raw, 2);
    $headers = parseHeaders($head . "\r\n\r\n");
    $contentLength = isset($headers['content-length']) ? (int) $headers['content-length'] : 0;
    $body = $body ?? '';
    if ($contentLength > strlen($body)) {
        $missing = readBytes($stream, $contentLength - strlen($body));
        if ($missing === null) {
            return null;
        }
        $body .= $missing;
    }

    return ['raw' => $head . "\r\n\r\n" . $body];
}

/**
 * @param resource $stream
 */
function readBytes($stream, int $length): ?string
{
    $data = '';
    $remaining = $length;
    while ($remaining > 0 && !feof($stream)) {
        $chunk = fread($stream, $remaining);
        if ($chunk === false || $chunk === '') {
            break;
        }
        $data .= $chunk;
        $remaining -= strlen($chunk);
    }

    return strlen($data) === $length ? $data : null;
}

function parseHeaders(string $raw): array
{
    $headers = [];
    $lines = explode("\r\n", $raw);
    for ($i = 1, $count = count($lines); $i < $count; $i++) {
        $line = $lines[$i];
        if ($line === '') {
            break;
        }
        $pos = strpos($line, ':');
        if ($pos === false) {
            continue;
        }
        $name = strtolower(trim(substr($line, 0, $pos)));
        $value = trim(substr($line, $pos + 1));
        $headers[$name] = $value;
    }

    return $headers;
}

function addProxyHeaders(string $raw, string $clientIp): string
{
    $parts = explode("\r\n\r\n", $raw, 2);
    $head = $parts[0];
    $body = $parts[1] ?? '';

    $lines = explode("\r\n", $head);
    if ($lines === [] || $lines[0] === '') {
        return $raw;
    }

    $hopByHop = [
        'connection' => true,
        'keep-alive' => true,
        'proxy-authenticate' => true,
        'proxy-authorization' => true,
        'proxy-connection' => true,
        'te' => true,
        'trailers' => true,
        'transfer-encoding' => true,
        'upgrade' => true,
    ];

    $forwarded = [$lines[0]];
    for ($i = 1, $count = count($lines); $i < $count; $i++) {
        $line = $lines[$i];
        if ($line === '') {
            continue;
        }
        $pos = strpos($line, ':');
        if ($pos === false) {
            continue;
        }
        $name = strtolower(trim(substr($line, 0, $pos)));
        if (isset($hopByHop[$name]) || $name === 'x-forwarded-proto' || $name === 'x-forwarded-for') {
            continue;
        }
        $forwarded[] = $line;
    }

    $forwarded[] = 'X-Forwarded-Proto: https';
    $forwarded[] = 'X-Forwarded-For: ' . $clientIp;
    $forwarded[] = 'Connection: close';

    return implode("\r\n", $forwarded) . "\r\n\r\n" . $body;
}

/**
 * @param resource $client
 */
function peerIp($client): string
{
    $peer = stream_socket_get_name($client, true);
    if (is_string($peer) && preg_match('/^([^:\]]+)/', $peer, $matches)) {
        return $matches[1];
    }

    return '127.0.0.1';
}
