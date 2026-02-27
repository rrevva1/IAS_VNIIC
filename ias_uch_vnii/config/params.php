<?php

return [
    'adminEmail' => 'admin@example.com',
    'senderEmail' => 'noreply@example.com',
    'senderName' => 'Example.com mailer',
    'bsVersion' => '5.0',
    /** Версия приложения (отображается на странице «О проекте») */
    'appVersion' => '1.0',
    /** URL микросервиса ИИ-помощника (Python). Если пусто — запросы не проксируются. */
    'assistantApiUrl' => getenv('ASSISTANT_API_URL') ?: 'http://127.0.0.1:8000',
];
