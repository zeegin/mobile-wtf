
&НаКлиенте
Процедура ОтправитьНаСервер(Команда)
	ОтправитьНаСерверНаСервере();
КонецПроцедуры

&НаСервере
Процедура ОтправитьНаСерверНаСервере()
	
	ОбработанныйНомерЗаказа = Строка(НомерЗаказа);
	ОбработанныйНомерЗаказа = СтрЗаменить(ОбработанныйНомерЗаказа, Символы.НПП, "");
	КоличествоСимволовЗаказа = СтрДлина(Строка(ОбработанныйНомерЗаказа));
		Пока КоличествоСимволовЗаказа < 11 Цикл
		ОбработанныйНомерЗаказа = "0" + ОбработанныйНомерЗаказа;
		КоличествоСимволовЗаказа = КоличествоСимволовЗаказа + 1;
	КонецЦикла;
	
	ОбработанныйКодОператора = Строка(КодОператора);
	ОбработанныйКодОператора = СтрЗаменить(ОбработанныйКодОператора, Символы.НПП, "");
	КоличествоСимволовОператора = СтрДлина(Строка(ОбработанныйКодОператора));
	Пока КоличествоСимволовОператора < 9 Цикл
		ОбработанныйКодОператора = "0" + ОбработанныйКодОператора;
		КоличествоСимволовОператора = КоличествоСимволовОператора + 1;
	КонецЦикла;
	  
	ОбработанныйНомерБухты = НомерБухты;
	ОбработанныйНомерБухты = СтрЗаменить(ОбработанныйНомерБухты, Символы.НПП, "");
	
	СтрЗапроса = Новый Структура;

	СтрЗапроса.Вставить("НомерЗаказа", ОбработанныйНомерЗаказа);
	СтрЗапроса.Вставить("НомерБухты", ОбработанныйНомерБухты);
	СтрЗапроса.Вставить("Оператор", ОбработанныйКодОператора);
	СтрЗапроса.Вставить("Операция", "SendPLK");
	СтрЗапроса.Вставить("ВидПродукции", "НС35");
	
	СтрЗапроса.Вставить("НомерКонтроллера", 10);
	
	Ответ = ПодключениеКВебСервисуПЛК(СтрЗапроса);
	
	УникальныйИдентификаторЗаказаНаПроизводство = Ответ.УникальныйИдентификаторЗаказаНаПроизводство;

	Если Ответ.Ошибка.ЕстьОшибка И НЕ Ответ.Ошибка.ТекстОшибки = "Не записано значение в ПЛК" Тогда
		Сообщить(Ответ.Ошибка.ТекстОшибки);	
	Иначе
		ЦветБухты 			= Ответ.Цвет;
		КвадратураЗаказа    = Ответ.Квадратура;
		Оператор			= Ответ.Оператор;
		ОстатокБухты	    = Ответ.Остаток;
		ТолщинаБухты		= Ответ.Толщина;
	
		ПараметрыЗаказа.Загрузить(Ответ.ПараметрыЗаказа);
		ИтогоМетровПогонных = ПараметрыЗаказа.Итог("КоличествоМП");
		ЭтаФорма.Элементы.Заказ.Видимость = Ложь;
		ЭтаФорма.Элементы.ПараметрЗаказа.Видимость = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ЭтаФорма.Элементы.ПараметрЗаказа.Видимость = Истина;
	ЭтаФорма.Элементы.Заказ.Видимость = Ложь;
КонецПроцедуры

&НаСервере
Процедура ВыполненоНаСервере()
	
	ПараметрЗавершениеЗаказа = ИнтеграционныйПЛК.НовыйПараметрЗавершенияЗаказа();
	ПараметрЗавершениеЗаказа.НомерКонтроллера = 10;
	ПараметрЗавершениеЗаказа.УИДЗаказаНаПроизводство = УникальныйИдентификаторЗаказаНаПроизводство;
	
	РезультатЗавершения = ИнтеграционныйПЛК.ЗавершитьЗаказ(ПараметрЗавершениеЗаказа);
	
	//////////////

	Если РезультатЗавершения.ЕстьОшибка Тогда
		Сообщить(РезультатЗавершения.ТекстОшибки);	
	Иначе
		Сообщить(РезультатЗавершения.СтатусЗаказа);	
		НомерЗаказа = 0;
		ЭтаФорма.Элементы.ПараметрЗаказа.Видимость = Ложь;	
		ЭтаФорма.Элементы.Заказ.Видимость = Истина;
	КонецЕсли;

	
КонецПроцедуры

&НаКлиенте
Процедура Выполнено(Команда)
	ВыполненоНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ВернутьсяКВводуЗаказа(Команда)
	ЭтаФорма.Элементы.ПараметрЗаказа.Видимость = Ложь;	
	ЭтаФорма.Элементы.Заказ.Видимость = Истина;
КонецПроцедуры

&НаСервере
Процедура ПрименитьНаСервере()
	СтрЗапроса = Новый Структура;
	
	СтрЗапроса.Вставить("УникальныйИдентификаторЗаказаНаПроизводство", УникальныйИдентификаторЗаказаНаПроизводство);
	СтрЗапроса.Вставить("Операция", "StartOrder");
	СтрЗапроса.Вставить("НомерКонтроллера", 10);
	СтрЗапроса.Вставить("ЯчейкаПробега", "D498");
		
	Ответ = ПодключениеКВебСервисуПЛК(СтрЗапроса);
	
	Если Ответ.Ошибка.ЕстьОшибка Тогда
		Сообщить(Ответ.Ошибка.ТекстОшибки);	
	Иначе
		Сообщить(Ответ.СтатусЗаказа);	
		НомерЗаказа = 0;
		ЭтаФорма.Элементы.ПараметрЗаказа.Видимость = Ложь;	
		ЭтаФорма.Элементы.Заказ.Видимость = Истина;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура Применить(Команда)
	ПрименитьНаСервере();
КонецПроцедуры



