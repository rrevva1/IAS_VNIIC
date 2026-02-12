<?php
// ====== Настройки страницы (можно менять) ======
$appName     = "IAS • Demo Page";
$appSubtitle = "Красивый шаблон PHP + HTML, без зависимостей";
$now         = new DateTime('now', new DateTimeZone('Europe/Moscow'));
$phpVersion  = PHP_VERSION;
$server      = $_SERVER['SERVER_SOFTWARE'] ?? 'Apache/PHP';
$host        = $_SERVER['HTTP_HOST'] ?? 'localhost';
$theme       = $_COOKIE['theme'] ?? 'auto'; // auto|light|dark

// Обработка формы (демо)
$msg = null;
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name  = trim($_POST['name']  ?? '');
    $email = trim($_POST['email'] ?? '');
    $text  = trim($_POST['text']  ?? '');
    if ($name && filter_var($email, FILTER_VALIDATE_EMAIL) && $text) {
        // В реальном проекте: запись в БД/отправка на почту.
        $msg = "Спасибо, $name! Ваше сообщение получено.";
    } else {
        $msg = "Проверьте поля формы — нужны имя, валидный email и сообщение.";
    }
}

// Переключение темы (cookie)
if (isset($_GET['theme'])) {
    $t = $_GET['theme'];
    if (in_array($t, ['auto','light','dark'], true)) {
        setcookie('theme', $t, time()+60*60*24*365, '/', '', false, true);
        header("Location: /pretty.php");
        exit;
    }
}
?>
<!DOCTYPE html>
<html lang="ru" data-theme="<?php echo htmlspecialchars($theme); ?>">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title><?php echo htmlspecialchars($appName); ?></title>
<meta name="description" content="Демо-страница на PHP с красивой вёрсткой без зависимостей" />
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'%3E%3Ccircle cx='32' cy='32' r='30' fill='%2300a3ff'/%3E%3Ctext x='32' y='39' font-size='28' text-anchor='middle' fill='white' font-family='Arial, sans-serif'%3Eɪ%3C/text%3E%3C/svg%3E" />
<style>
  :root{
    --bg: #0b0d12;
    --panel: #121826;
    --text: #e8eefc;
    --muted:#9fb0d0;
    --accent:#4cc9f0;
    --accent-2:#a5f3fc;
    --ok:#22c55e;
    --warn:#f59e0b;
    --err:#ef4444;
    --ring: rgba(76,201,240,.35);
    --shadow: 0 10px 30px rgba(0,0,0,.35);
    --card: linear-gradient(180deg, rgba(255,255,255,.04), rgba(255,255,255,.02));
  }
  [data-theme="light"]{
    --bg:#f6f7fb; --panel:#ffffff; --text:#0f172a; --muted:#46556f;
    --accent:#2563eb; --accent-2:#60a5fa; --ring: rgba(37,99,235,.25);
    --shadow: 0 8px 24px rgba(0,0,0,.1); --card: linear-gradient(180deg, rgba(0,0,0,.03), rgba(0,0,0,.02));
  }
  *{box-sizing:border-box}
  body{
    margin:0; background:radial-gradient(1200px 600px at 10% -10%, rgba(76,201,240,.12), transparent),
              radial-gradient(900px 500px at 110% 10%, rgba(165,243,252,.14), transparent),
              var(--bg);
    color:var(--text); font: 16px/1.6 "Inter", system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;
  }
  a{color:var(--accent); text-decoration:none}
  a:hover{text-decoration:underline}
  .container{max-width:1100px; margin:0 auto; padding:24px}
  .nav{
    display:flex; align-items:center; justify-content:space-between;
    padding:14px 20px; margin:16px auto; border-radius:16px; background:var(--panel); box-shadow:var(--shadow);
  }
  .brand{display:flex; gap:12px; align-items:center}
  .logo{
    width:36px; height:36px; border-radius:10px;
    background: conic-gradient(from 220deg, var(--accent), var(--accent-2), var(--accent));
    box-shadow:0 0 0 6px rgba(76,201,240,.08), 0 6px 20px rgba(76,201,240,.35);
  }
  .brand h1{font-size:18px; margin:0}
  .nav-actions a, .nav-actions form button{
    display:inline-flex; align-items:center; gap:8px; padding:8px 12px; border-radius:10px; border:1px solid transparent;
    background:var(--card); color:var(--text);
  }
  .nav-actions a:hover{border-color:var(--accent); box-shadow:0 0 0 4px var(--ring)}
  .hero{
    margin:28px auto; padding:36px; border-radius:20px; background:
      radial-gradient(700px 200px at 20% -10%, rgba(76,201,240,.18), transparent),
      radial-gradient(500px 200px at 130% 10%, rgba(165,243,252,.18), transparent),
      var(--panel);
    box-shadow:var(--shadow);
    display:grid; gap:18px;
  }
  .hero h2{font-size:32px; line-height:1.2; margin:0}
  .hero p{color:var(--muted); margin:0}
  .grid{display:grid; gap:16px; grid-template-columns:repeat(12, 1fr)}
  .col-4{grid-column: span 4}
  .col-6{grid-column: span 6}
  .col-12{grid-column: span 12}
  @media (max-width:900px){
    .col-4{grid-column: span 12}
    .col-6{grid-column: span 12}
  }
  .card{
    background:var(--panel); border-radius:16px; padding:20px; box-shadow:var(--shadow); border:1px solid rgba(255,255,255,.06);
  }
  .card h3{margin:0 0 6px 0; font-size:18px}
  .muted{color:var(--muted)}
  .badge{display:inline-block; padding:2px 8px; border-radius:999px; font-size:12px; background:var(--card); border:1px solid rgba(255,255,255,.06)}
  .btn{
    display:inline-flex; align-items:center; justify-content:center; gap:8px;
    padding:10px 14px; border-radius:12px; border:1px solid rgba(255,255,255,.08);
    background:linear-gradient(180deg, rgba(255,255,255,.06), rgba(255,255,255,.02));
    color:var(--text); cursor:pointer;
  }
  .btn:hover{box-shadow:0 0 0 6px var(--ring)}
  .btn-primary{background: linear-gradient(180deg, var(--accent), var(--accent-2)); border-color: transparent; color:#001b2a}
  .btn-ghost{background:var(--card)}
  .input, textarea{
    width:100%; padding:10px 12px; border-radius:12px; border:1px solid rgba(255,255,255,.12);
    background:linear-gradient(180deg, rgba(255,255,255,.05), rgba(255,255,255,.03)); color:var(--text);
    outline:none;
  }
  .input:focus, textarea:focus{box-shadow:0 0 0 6px var(--ring)}
  .row{display:grid; gap:12px; grid-template-columns:1fr 1fr}
  @media (max-width:700px){ .row{grid-template-columns:1fr} }
  .footer{margin:28px auto; padding:16px; text-align:center; color:var(--muted)}
  .alert{padding:12px 14px; border-radius:12px; margin:10px 0; border:1px solid rgba(255,255,255,.12)}
  .alert.ok{background:rgba(34,197,94,.1); border-color:rgba(34,197,94,.4)}
  .alert.warn{background:rgba(245,158,11,.08); border-color:rgba(245,158,11,.45)}
</style>
<script>
// Авто-тема: если выбран "auto", синхронизируемся с prefer-color-scheme
(function(){
  const root = document.documentElement;
  const prefDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  if(root.dataset.theme === 'auto') root.dataset.theme = prefDark ? 'dark' : 'light';
})();
</script>
</head>
<body>
  <div class="container">
    <!-- Навбар -->
    <div class="nav">
      <div class="brand">
        <div class="logo" aria-hidden="true"></div>
        <h1><?php echo htmlspecialchars($appName); ?></h1>
      </div>
      <div class="nav-actions">
        <a href="?theme=auto"  title="Авто-тема">Авто</a>
        <a href="?theme=light" title="Светлая">Светлая</a>
        <a href="?theme=dark"  title="Тёмная">Тёмная</a>
      </div>
    </div>

    <!-- Герой -->
    <section class="hero">
      <h2><?php echo htmlspecialchars($appSubtitle); ?></h2>
      <p>Сервер: <b><?php echo htmlspecialchars($server); ?></b> • PHP <b><?php echo htmlspecialchars($phpVersion); ?></b> • Хост: <b><?php echo htmlspecialchars($host); ?></b> • Время: <b><?php echo $now->format('d.m.Y H:i:s'); ?></b></p>
      <div>
        <a class="btn btn-primary" href="/pretty.php#form">Оставить сообщение</a>
        <a class="btn btn-ghost" href="/info.php" target="_blank">phpinfo()</a>
      </div>
    </section>

    <!-- Контентные карточки -->
    <div class="grid">
      <div class="col-4">
        <div class="card">
          <div class="badge">Статус</div>
          <h3>Проверка окружения</h3>
          <p class="muted">Мини-диагностика вашего сервера.</p>
          <ul>
            <li>Документ-корень: <code>/var/www/ias_uch_vnii/web</code></li>
            <li>Включён rewrite: <b class="muted">проверьте a2enmod rewrite</b></li>
            <li>Yii cookie key: <code><?php echo getenv('YII_COOKIE_VALIDATION_KEY') ? 'OK (env)' : '—'; ?></code></li>
          </ul>
        </div>
      </div>

      <div class="col-4">
        <div class="card">
          <div class="badge">UI</div>
          <h3>Адаптивная сетка</h3>
          <p class="muted">Сетка 12 колонок с авто-адаптацией под мобильные устройства. Никаких внешних CSS, только встраиваемые стили.</p>
          <button class="btn" onclick="alert('Привет, Ruslan! 🎉')">Проверить JS</button>
        </div>
      </div>

      <div class="col-4">
        <div class="card">
          <div class="badge">PHP</div>
          <h3>Шаблон для старта</h3>
          <p class="muted">Скопируйте файл как <code>index.php</code> или подключите через <code>include</code>/<code>require</code> в вашем фреймворке.</p>
          <pre class="muted" style="white-space:pre-wrap;margin:0">sudo cp pretty.php /var/www/ias_uch_vnii/web/index.php</pre>
        </div>
      </div>

      <!-- Форма -->
      <div class="col-6" id="form">
        <div class="card">
          <div class="badge">Форма</div>
          <h3>Обратная связь</h3>
          <?php if ($msg): ?>
            <div class="alert <?php echo strpos($msg,'Спасибо')===0 ? 'ok':'warn'; ?>"><?php echo htmlspecialchars($msg); ?></div>
          <?php endif; ?>
          <form method="post" action="#form" novalidate>
            <div class="row">
              <div><input class="input" type="text" name="name" placeholder="Ваше имя" required></div>
              <div><input class="input" type="email" name="email" placeholder="Email" required></div>
            </div>
            <div style="margin-top:12px">
              <textarea class="input" name="text" rows="5" placeholder="Сообщение..." required></textarea>
            </div>
            <div style="margin-top:12px; display:flex; gap:10px; align-items:center">
              <button class="btn btn-primary" type="submit">Отправить</button>
              <button class="btn" type="reset">Сброс</button>
            </div>
          </form>
        </div>
      </div>

      <!-- Инфо-блок -->
      <div class="col-6">
        <div class="card">
          <div class="badge">Информация</div>
          <h3>Полезные ссылки</h3>
          <ul>
            <li><a href="/pretty.php">Главная страница демо</a></li>
            <li><a href="/info.php" target="_blank">phpinfo() (для диагностики)</a></li>
            <li><a href="/" >Корень виртуального хоста</a></li>
          </ul>
          <p class="muted">Совет: в продакшене отключайте <code>phpinfo()</code> и показ ошибок, используйте логи Apache/PHP-FPM.</p>
        </div>
      </div>
    </div>

    <div class="footer">
      © <?php echo date('Y'); ?> <?php echo htmlspecialchars($appName); ?> · Сделано с ❤ на PHP
    </div>
  </div>
</body>
</html>
