#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ТекущееСостояние = "ПараметрЗаказа";
	// Возможные состояния:
	// * Заказ
	// * ПараметрЗаказа
	// * ЕстьОшибка
	// * ОтобразитьСтатусЗаказа
	
	УправлениеФормой();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВернутьсяКВводуЗаказа(Команда)
	
	ТекущееСостояние = "Заказ";
	УправлениеФормой();

КонецПроцедуры

&НаКлиенте
Процедура Выполнено(Команда)
	ВыполненоНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ОтправитьНаСервер(Команда)
	ОтправитьНаСерверНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура Применить(Команда)
	ПрименитьНаСервере();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ВыполненоНаСервере()
	
	ПараметрЗавершениеЗаказа = ИнтеграционныйПЛК.НовыйПараметрЗавершенияЗаказа();
	ПараметрЗавершениеЗаказа.УИДЗаказаНаПроизводство = УникальныйИдентификаторЗаказаНаПроизводство;
	
	РезультатЗавершения = ИнтеграционныйПЛК.ЗавершитьЗаказ(ПараметрЗавершениеЗаказа);
	
	//////////////

	ТекстОшибки = "";
	СтатусЗаказа = "";

	Если РезультатЗавершения.ЕстьОшибка Тогда
		ТекстОшибки = РезультатЗавершения.ТекстОшибки;
		ТекущееСостояние = "ЕстьОшибка";
		УправлениеФормой("ПараметрЗаказа");
	Иначе
		НомерЗаказа = 0;
		СтатусЗаказа = РезультатЗавершения.СтатусЗаказа;
		ТекущееСостояние = "ОтобразитьСтатусЗаказа";
		УправлениеФормой("Заказ");
	КонецЕсли;
	
	УправлениеФормой();
	
КонецПроцедуры

&НаСервере
Процедура ОтправитьНаСерверНаСервере()
	
	ПараметрОтправкиHC35 = ИнтеграционныйПЛК.НовыйПараметрОтправкиHC35();
	ПараметрОтправкиHC35.ОбработанныйНомерЗаказа = НомерЗаказа;
	ПараметрОтправкиHC35.ОбработанныйНомерБухты = НомерБухты;
	ПараметрОтправкиHC35.ОбработанныйКодОператора = КодОператора;
	
	Ответ = ИнтеграционныйПЛК.ОтправитьHC35(ПараметрОтправкиHC35);
	
	УникальныйИдентификаторЗаказаНаПроизводство = Ответ.УникальныйИдентификаторЗаказаНаПроизводство;

	Если Ответ.ЕстьОшибка Тогда
		ТекстОшибки = Ответ.ТекстОшибки;
		ТекущееСостояние = "ЕстьОшибка";
		УправлениеФормой("ПараметрЗаказа");
	Иначе
		ЦветБухты        = Ответ.Цвет;
		КвадратураЗаказа = Ответ.Квадратура;
		Оператор         = Ответ.Оператор;
		ОстатокБухты     = Ответ.Остаток;
		ТолщинаБухты     = Ответ.Толщина;
		
		ПараметрыЗаказа.Загрузить(Ответ.ПараметрыЗаказа);
		
		ИтогоМетровПогонных = ПараметрыЗаказа.Итог("КоличествоМП");
		
		ТекущееСостояние = "ПараметрЗаказа";
		УправлениеФормой();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПрименитьНаСервере()
	
	ПараметрНачалаЗаказа = ИнтеграционныйПЛК.НовыйПараметрНачалаЗаказа();
	ПараметрНачалаЗаказа.УИДЗаказаНаПроизводство = УникальныйИдентификаторЗаказаНаПроизводство;
	
	Ответ = ИнтеграционныйПЛК.НачатьЗаказ(ПараметрНачалаЗаказа);
	
	//
	
	Если Ответ.ЕстьОшибка Тогда
		ТекстОшибки = Ответ.ТекстОшибки;
		ТекущееСостояние = "ЕстьОшибка";
		УправлениеФормой("ПараметрЗаказа");
	Иначе
		НомерЗаказа = 0;
		СтатусЗаказа = Ответ.СтатусЗаказа;
		ТекущееСостояние = "ОтобразитьСтатусЗаказа";
		УправлениеФормой("Заказ");
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура УправлениеФормой(СледующееСостояние = "")
	
	Если ТекущееСостояние = "ПараметрЗаказа" Тогда
	
		Элементы.ПараметрЗаказа.Видимость = Истина;
		Элементы.Заказ.Видимость = Ложь;
	
	ИначеЕсли ТекущееСостояние = "Заказ" Тогда
		
		Элементы.ПараметрЗаказа.Видимость = Ложь;	
		Элементы.Заказ.Видимость = Истина;
		
	ИначеЕсли ТекущееСостояние = "ЕстьОшибка" Тогда
		
		Сообщить(ТекстОшибки);
		
	ИначеЕсли ТекущееСостояние = "ОтобразитьСтатусЗаказа" Тогда
		
		Сообщить(СтатусЗаказа);
		
	Иначе
		
		ВызватьИсключение Стршаблон(НСтр("ru = 'Необрабатываемое состояние формы %1'"), ТекущееСостояние);
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СледующееСостояние) Тогда
		ТекущееСостояние = СледующееСостояние;
		УправлениеФормой();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
