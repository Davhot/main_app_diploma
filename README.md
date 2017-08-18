# README

## Формат POST - запроса для отправки лога на [url]/main_hot_catch_logs
* log_data - данные лога
* name_app - название приложения, из которого отправляется лог
* count_log - количество логов
* id_log_origin_app - id лога, хранящийся в базе в приложении, откуда отправлен лог
* from_log - из какой части приложения прибыл лог
Значения: [Rails|Client|Puma|Nginx]
* status - статус лога, если есть
Значения: [STATUS|SUCCESS|REDIRECTION|CLIENT_ERROR|SERVER_ERROR|WARNING]

P.S. id_log_origin_app и name_app уникальны в совокупности, следовательно
все логи от одного приложения должны находиться в одной таблице базы данных.
Кроме того, можно не присылать count_log, по умолчанию единица.

Гем, предоставляющий возможность отправки логов в главное приложение и логирующий все запросы в базу данных:
`gem hot_catch`

Пример запроса:
`{main_hot_catch_logs: {
  "log_data":"some message",
  "name_app":"diploma_app",
  "count_log":"1",
  "id_log_origin_app":"2",
  "from_log":"Rails",
  "status":"SERVER_ERROR"}
}`
