/*
Выборка всех данных из каждой таблицы
*/
CREATE OR REPLACE VIEW visitors_view
	AS SELECT * FROM visitors;
CREATE OR REPLACE VIEW addresses_view
	AS SELECT * FROM addresses;
CREATE OR REPLACE VIEW waiters_view
	AS SELECT * FROM waiters;
CREATE OR REPLACE VIEW halls_view
	AS SELECT * FROM halls;
CREATE OR REPLACE VIEW events_view
	AS SELECT * FROM events;
CREATE OR REPLACE VIEW bookings_view
	AS SELECT * FROM bookings;
CREATE OR REPLACE VIEW event_orders_view
	AS SELECT * FROM event_orders;


/*
Выборка данных из одной таблицы при нескольких условиях
*/
CREATE OR REPLACE VIEW bookings_full_after_15_view
	AS SELECT booking_date, time_start, time_end, hall_id, full_hall FROM bookings
		WHERE full_hall AND time_start > '15:00:00';

CREATE OR REPLACE VIEW addresses_not_SPB_view
	AS SELECT * FROM addresses WHERE street NOT LIKE '%Санкт-Петербург%';

CREATE OR REPLACE VIEW bookings_bef_or_aft_15_view
	AS SELECT booking_date, time_start, time_end, hall_id, full_hall FROM bookings
		WHERE '15:00:00' NOT BETWEEN time_start AND time_end;

CREATE OR REPLACE VIEW waiters_in_names_view
	AS SELECT * FROM waiters WHERE name IN ('Алексей', 'Мария', 'Илья');


/*
Создание в запросе вычисляемого поля
*/
CREATE OR REPLACE VIEW bookings_with_full_time_view
	AS SELECT *, time_end - time_start as full_time FROM bookings;


/*
Выборка всех данных с сортировкой по нескольким полям
*/
CREATE OR REPLACE VIEW bookings_sorted_view
	AS SELECT visitor_id, COUNT(*) as bookings_count, SUM(time_end - time_start) as full_time
		FROM bookings GROUP BY visitor_id ORDER BY bookings_count DESC, full_time DESC;


/*
Запрос, вычисляющий несколько совокупных характеристик таблиц
*/
CREATE OR REPLACE VIEW events_join_event_orders_view
	AS SELECT name, price, COUNT(*) as count, price * COUNT(*) as full_sum,
		show_time, AVG(start_time - '0:00:00' + show_time) as middle_end_time
		FROM events JOIN event_orders ON event_id = events.id GROUP BY events.id;


/*
Выборка данных из связанных таблиц (не менее двух примеров)
*/
CREATE OR REPLACE VIEW bookings_join_visiters_view
	AS SELECT surname, name, patronymic, COUNT(*) as bookings_count,
		SUM(time_end - time_start) as full_time
		FROM bookings JOIN visitors ON visitors.id = visitor_id
		GROUP BY visitors.id ORDER BY bookings_count DESC, full_time DESC;

CREATE OR REPLACE VIEW waiters_join_addresses_view
	AS SELECT surname, name, patronymic, street, building
		FROM waiters JOIN addresses ON waiters.address_id = addresses.id;


/*
Создайте запрос, рассчитывающий совокупную характеристику с использованием группировки,
наложите ограничение на результат группировки
*/
CREATE OR REPLACE VIEW bookings_join_event_orders_after_15_view
	AS SELECT bookings.id, COUNT(*) as events_count, SUM(events.price) as full_price
		FROM bookings JOIN event_orders ON booking_id = bookings.id
		JOIN events ON event_id = events.id
		GROUP BY bookings.id HAVING time_start >= '15:00:00';


/*
Пример использования вложенного запроса
*/
CREATE OR REPLACE VIEW bookings_hall_for_id10_view
	AS SELECT * FROM bookings WHERE hall_id = (SELECT hall_id FROM bookings WHERE id = 10);


/*
С помощью оператора INSERT добавьте в каждую таблицу по одной записи
*/
CREATE OR REPLACE PROCEDURE insert_into_visitors() LANGUAGE SQL
AS $$
	INSERT INTO visitors (name, surname, patronymic, phone)
		VALUES ('Иванов', 'И.', 'А.', 89936721125)
$$;

CREATE OR REPLACE PROCEDURE insert_into_addresses() LANGUAGE SQL
AS $$
	INSERT INTO addresses (street, building)
		VALUES ('Ул. Строителей', 5)
$$;

CREATE OR REPLACE PROCEDURE insert_into_waiters() LANGUAGE SQL
AS $$
	INSERT INTO waiters (name, surname, patronymic, address_id)
		VALUES ('Иванова', 'А.', 'И.', 101)
$$;

CREATE OR REPLACE PROCEDURE insert_into_halls() LANGUAGE SQL
AS $$
	INSERT INTO halls (hall_num, address_id, tables_count)
		VALUES (1, 101, 8)
$$;

CREATE OR REPLACE PROCEDURE insert_into_events() LANGUAGE SQL
AS $$
	INSERT INTO events (name, price, show_time)
		VALUES ('Fireshow', 5000, '01:30:00')
$$;

CREATE OR REPLACE PROCEDURE insert_into_bookings() LANGUAGE SQL
AS $$
	INSERT INTO bookings (booking_date, time_start, time_end,
		visitor_id, hall_id, full_hall, table_num)
		VALUES ('2022-11-02', '12:00:00', '16:00:00', 10001, 1001, true, 0)
$$;

CREATE OR REPLACE PROCEDURE insert_into_event_orders() LANGUAGE SQL
AS $$
	INSERT INTO event_orders (event_id, start_time, booking_id)
		VALUES (1001, '12:30:00', 10001)
$$;


/*
С помощью оператора UPDATE измените значения нескольких полей у всех записей,
отвечающих заданному условию
*/
CREATE OR REPLACE PROCEDURE update_bookings() LANGUAGE SQL
AS $$
	UPDATE bookings SET full_hall = false, table_num = 1
		WHERE full_hall AND hall_id = 6;
$$;


/*
С помощью оператора DELETE удалите запись, имеющую максимальное (минимальное)
значение некоторой совокупной характеристики
*/
CREATE OR REPLACE PROCEDURE delete_from_event_orders() LANGUAGE SQL
AS $$
	DELETE FROM event_orders WHERE start_time =
		(SELECT MAX(start_time) FROM event_orders);
$$;


/*
С помощью оператора DELETE удалите записи в главной таблице, на которые не ссылается
подчиненная таблица (используя вложенный запрос)
*/
CREATE OR REPLACE PROCEDURE delete_from_bookings() LANGUAGE SQL
AS $$
	DELETE FROM bookings WHERE id NOT IN (SELECT booking_id FROM event_orders);
$$;


/*
Выполнение процедур
*/
CALL insert_into_visitors();
CALL insert_into_addresses();
CALL insert_into_waiters();
CALL insert_into_halls();
CALL insert_into_events();
CALL insert_into_bookings();
CALL insert_into_event_orders();
CALL update_bookings();
CALL delete_from_event_orders();
CALL delete_from_bookings();
