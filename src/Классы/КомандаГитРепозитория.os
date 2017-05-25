Перем ПараметрыКоманды Экспорт;
Перем ГитРепозиторий Экспорт;
Перем КомандаГит Экспорт;
Перем КлассНастройкиКоманды;
Перем ПлагиныОбработчики;
Перем Отказ;
Перем СтандартнаяОбработка;
Перем РефлекторПроверкиКоманд;


// Установить команды git для выполнения.
//
// Параметры:
//   НоваяКомандаГит - строка - строковое представление команды git
//                                                          
Процедура УстановитьКоманду(Знач НоваяКомандаГит) Экспорт

	КомандаГит = НоваяКомандаГит;
	
КонецПроцедуры

// Установить контекст выполнения команды git.
//
// Параметры:
//   КонтекстВыполненияКоманды - ГитРепозиторий - инстанс класса ГитРепозиторий с необходимыми
//                                                          настройками
Процедура УстановитьКонтекст(КонтекстВыполненияКоманды) Экспорт
	
	ГитРепозиторий = КонтекстВыполненияКоманды;

КонецПроцедуры

// Добавление дополнительных контекстов выполнения команды git.
//
// Параметры:
//   КонтекстВыполненияКоманды - Произвольный класс - инстанс класса с реализацией дополнительных обработчиков
//     
Процедура ДобавитьКонтекстВыполнения(КонтекстВыполненияКоманды) Экспорт

	ПлагиныОбработчики.Вставить(КонтекстВыполненияКоманды);

КонецПроцедуры

// Установить настройку выполнения команды git.
//
// Параметры:
//   НовыйКлассНастройкиКоманды - Произвольный класс - инстанс класса реализующего настройки выполнения команды
// 
Процедура УстановитьНастройкуКоманды(НовыйКлассНастройкиКоманды) Экспорт

	КлассНастройкиКоманды = НовыйКлассНастройкиКоманды;

КонецПроцедуры

// Процедура выполнения команды git
Процедура ВыполнитьКоманду() Экспорт

	ПередВыполнением_НастройкаКоманды();
	ПередВыполнением_ПодпискиПлагинов();
	ПередВыполнением_СтандартнаяОбработка();
	
	ПараметрыКоманды.Вставить(0, КомандаГит);

	ПриВыполнении_НастройкаКоманды();	
	ПриВыполнении_ПодпискиПлагинов();
	ПриВыполнении_СтандартнаяОбработка();
	
	ПослеВыполнения_НастройкаКоманды();
	ПослеВыполнения_ПодпискиПлагинов();
	ПослеВыполнения_СтандартнаяОбработка();
	
КонецПроцедуры

///////////////////
// ОБРАБОТЧИКИ НАСТРОЙКИ КОМАНДЫ


Процедура ПередВыполнением_НастройкаКоманды()

	Если Не ПроверитьОбработчикПередВыполнением(КлассНастройкиКоманды) Тогда
		Возврат;
	КонецЕсли;

	КлассНастройкиКоманды.ПередВыполнением(Отказ, ПараметрыКоманды, СтандартнаяОбработка);

КонецПроцедуры

Процедура ПриВыполнении_НастройкаКоманды()
	
	Если Не ПроверитьОбработчикПриВыполнении(КлассНастройкиКоманды) Тогда
		Возврат;
	КонецЕсли;

	КлассНастройкиКоманды.ПриВыполнении(КомандаГит, ПараметрыКоманды, ГитРепозиторий,  СтандартнаяОбработка);

КонецПроцедуры

Процедура ПослеВыполнения_НастройкаКоманды()

	Если Не ПроверитьОбработчикПослеВыполнения(КлассНастройкиКоманды) Тогда
		Возврат;
	КонецЕсли;

	КлассНастройкиКоманды.ПослеВыполнения(СтандартнаяОбработка);

КонецПроцедуры


///////////////////
// СТАНДАРТНЫЕ ОБРАБОТЧИКИ

Процедура ПередВыполнением_СтандартнаяОбработка()

	Если НЕ СтандартнаяОбработка Тогда
		Возврат;
	КонецЕсли;

	ТиповаяФункция = "ПолучитьПараметрыКоманды";

	Если Не ПроверитьМетодКласса(КлассНастройкиКоманды, ТиповаяФункция, , Истина) Тогда
		Сообщение = СтрШаблон(
			"У класса %1 не реализована обязательная функция: %2",
			КлассНастройкиКоманды,
			ТиповаяФункция
		);
		ВызватьИсключение Сообщение;
	КонецЕсли;

	ПараметрыКоманды = КлассНастройкиКоманды.ПолучитьПараметрыКоманды();

КонецПроцедуры

Процедура ПриВыполнении_СтандартнаяОбработка()
	
	Если Отказ Тогда
		ВызватьИсключение "Выполнение команды прервано";
	КонецЕсли;

	ГитРепозиторий.ВыполнитьКоманду(ПараметрыКоманды); 

КонецПроцедуры

Процедура ПослеВыполнения_СтандартнаяОбработка()
	// Действий по умолчанию не требуется
	Возврат;
КонецПроцедуры

//////////////////////
// ОБРАБОТКИ ПЛАГИНОВ И ПОДПИСОК

Процедура ПередВыполнением_ПодпискиПлагинов()
	
	Для каждого Плагин Из ПлагиныОбработчики Цикл
		
		КлассРеализацииКоманды = Плагин.Ключ;
		
		Если ПроверитьОбработчикПередВыполнением(КлассРеализацииКоманды) Тогда
			Продолжить;
		КонецЕсли;
		
		КлассРеализацииКоманды.ПередВыполнением(Отказ, ПараметрыКоманды, СтандартнаяОбработка);

	КонецЦикла;

КонецПроцедуры

Процедура ПриВыполнении_ПодпискиПлагинов()
	
	Для каждого Плагин Из ПлагиныОбработчики Цикл
		
		КлассРеализацииКоманды = Плагин.Ключ;
		
		Если ПроверитьОбработчикПриВыполнении(КлассРеализацииКоманды) Тогда
			Продолжить;
		КонецЕсли;
		
		КлассРеализацииКоманды.ПриВыполнении(КомандаГит, ПараметрыКоманды, ГитРепозиторий, Отказ, СтандартнаяОбработка);
	
	КонецЦикла;

КонецПроцедуры

Процедура ПослеВыполнения_ПодпискиПлагинов()
	
	Для каждого Плагин Из ПлагиныОбработчики Цикл
		
		КлассРеализацииКоманды = Плагин.Ключ;
		
		Если ПроверитьОбработчикПослеВыполнения(КлассРеализацииКоманды) Тогда
			Продолжить;
		КонецЕсли;

		КлассРеализацииКоманды.ПослеВыполнения(КомандаГит, ПараметрыКоманды, ГитРепозиторий, СтандартнаяОбработка);
	
	КонецЦикла;

КонецПроцедуры

///////////////////////////
// ПРОЦЕДУРЫ РЕФЛЕКТОРА

Функция ПроверитьОбработчикПередВыполнением(КлассРеализацииКоманды)

	ИмяМетода = "ПередВыполнением";
	ТребуемоеКоличествоПараметров = 3;
	ЭтоФункция = Ложь;
	
	Возврат ПроверитьМетодКласса(КлассРеализацииКоманды, ИмяМетода, ТребуемоеКоличествоПараметров, ЭтоФункция);
	
КонецФункции

Функция ПроверитьОбработчикПриВыполнении(КлассРеализацииКоманды)

	ИмяМетода = "ПриВыполнении";
	ТребуемоеКоличествоПараметров = 5;
	ЭтоФункция = Ложь;
	
	Возврат ПроверитьМетодКласса(КлассРеализацииКоманды, ИмяМетода, ТребуемоеКоличествоПараметров, ЭтоФункция);
	
КонецФункции

Функция ПроверитьОбработчикПослеВыполнения(КлассРеализацииКоманды)

	ИмяМетода = "ПослеВыполнения";
	ТребуемоеКоличествоПараметров = 4;
	ЭтоФункция = Ложь;
	
	Возврат ПроверитьМетодКласса(КлассРеализацииКоманды, ИмяМетода, ТребуемоеКоличествоПараметров, ЭтоФункция);
	
КонецФункции

Функция ПроверитьМетодКласса(Знач КлассРеализацииКоманды,
	                         Знач ИмяМетода,
							 Знач ТребуемоеКоличествоПараметров = 0,
							 Знач ЭтоФункция = Ложь)

	ЕстьМетод = РефлекторПроверкиКоманд.МетодСуществует(КлассРеализацииКоманды, ИмяМетода);

	Если Не ЕстьМетод Тогда
		Возврат Ложь;
	КонецЕсли;

	ТаблицаМетодов = ПолучитьТаблицуМетодов(КлассРеализацииКоманды);
	СтрокаМетода = ТаблицаМетодов.Найти(ИмяМетода, "Имя");
	Если СтрокаМетода = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;

	ПроверкаНаФункцию = ЭтоФункция = СтрокаМетода.ЭтоФункция;
	ПроверкаНаКоличествоПараметров = ТребуемоеКоличествоПараметров = СтрокаМетода.КоличествоПараметров;

	//Сообщить(СтрШаблон("Класс %1 метод %2: %3", КлассРеализацииКоманды, ИмяМетода, ПроверкаНаФункцию 
	//		И ПроверкаНаКоличествоПараметров ));

	Возврат ПроверкаНаФункцию 
			И ПроверкаНаКоличествоПараметров;

	
КонецФункции // ПроверитьМетодУКласса()

Функция ПолучитьТаблицуМетодов(Знач КлассРеализацииКоманды)

	Возврат РефлекторПроверкиКоманд.ПолучитьТаблицуМетодов(КлассРеализацииКоманды);
	
КонецФункции

Процедура Инициализация()

	ПлагиныОбработчики = Новый Соответствие;
	ПараметрыКоманды = Новый Массив;
	РефлекторПроверкиКоманд = Новый Рефлектор;
	СтандартнаяОбработка = Истина;
	Отказ = ложь;
КонецПроцедуры

Инициализация();