<?php
/**
 * HTTP -> HTTPS redirect for local dev (port 8880 by default).
 */

declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    exit(1);
}

$options = getopt('', ['listen:', 'port:', 'https-port:']);
$listen = (string) ($options['listen'] ?? '0.0.0.0');
$port = (int) ($options['port'] ?? 8880);
$httpsPort = (int) ($options['https-port'] ?? 8888);

$server = @stream_socket_server(
    "tcp://{$listen}:{$port}",
    $errno,
    $errstr,
    STREAM_SERVER_BIND | STREAM_SERVER_LISTEN
);
if ($server === false) {
    fwrite(STDERR, "Cannot bind tcp://{$listen}:{$port}: {$errstr} ({$errno})\n");
    exit(1);
}

fwrite(STDOUT, "HTTP redirect on {$listen}:{$port} -> https://...:{$httpsPort}\n");

while (true) {
    $client = @stream_socket_accept($server, -1);
    if ($client === false) {
        continue;
    }
    stream_set_timeout($client, 3);
    $data = '';
    while (strpos($data, "\r\n\r\n") === false && !feof($client)) {
        $chunk = fread($client, 4096);
        if ($chunk === false || $chunk === '') {
            break;
        }
        $data .= $chunk;
    }

    $hostHeader = 'localhost:' . $httpsPort;
    if (preg_match('/^Host:\s*([^\r\n]+)/mi', $data, $matches)) {
        $host = trim($matches[1]);
        $hostHeader = strpos($host, ':') === false ? $host . ':' . $httpsPort : preg_replace('/:\d+$/', ':' . $httpsPort, $host);
    }

    $path = '/';
    if (preg_match('/^[A-Z]+\s+(\S+)/', $data, $pathMatch)) {
        $path = $pathMatch[1];
    }

    $location = 'https://' . $hostHeader . ($path === '/' ? '/' : $path);
    $body = "Redirecting to HTTPS...\n";
    $response = "HTTP/1.1 301 Moved Permanently\r\n"
        . 'Location: ' . $location . "\r\n"
        . "Content-Type: text/plain; charset=UTF-8\r\n"
        . 'Content-Length: ' . strlen($body) . "\r\n"
        . "Connection: close\r\n\r\n"
        . $body;
    fwrite($client, $response);
    fclose($client);
}
