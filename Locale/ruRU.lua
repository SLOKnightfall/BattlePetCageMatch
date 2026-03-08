local AddOnFolderName, private = ...

-- See http://wow.curseforge.com/addons/ion-status-bars/localization/
local L = _G.LibStub("AceLocale-3.0"):NewLocale("BattlePetCageMatch", "ruRU", true)

if not L then return end
--Translator ZamestoTV
 local commandColor = "FFFFC654";


L.OPTIONS_HEADER = "Настройки"
L.OPTIONS_SHOW_BUTTON = "Показывать кнопку «В клетку» в журнале питомцев"
L.OPTIONS_SHOW_BUTTON_TOOLTIP = ""
L.OPTIONS_TRADEABLE = "Показывать иконку «Нельзя в клетку»"
L.OPTIONS_TRADEABLE_TOOLTIP = "Включает/выключает метку для питомцев, которых нельзя поместить в клетку"
L.OPTIONS_GLOBAL_LIST = "Показывать клетки с других серверов"
L.OPTIONS_GLOBAL_LIST_TOOLTIP = "Показывает/скрывает иконку списка, если в базе есть клетки с других серверов."
L.OPTIONS_INV_TOOLTIPS = "Добавлять количество в инвентаре в подсказку клетки"
L.OPTIONS_ICON_TOOLTIPS = "Добавлять подсказки к иконке питомца в журнале"
L.OPTIONS_ICON_TOOLTIPS_1 = "Показывать клетки у текущего персонажа"
L.OPTIONS_ICON_TOOLTIPS_2 = "Показывать цену по TSM"
L.OPTIONS_ICON_TOOLTIPS_3 = "Показывать клетки у других персонажей"
L.OPTIONS_CAGE_HEADER = "Настройки авто-помещения в клетку"

L.OPTIONS_CAGE_CUSTOM_TOOLTIP = "Это значение будет сравниваться с выбранным источником TSM."
L.OPTIONS_CAGE_CONFIRM = "Требовать подтверждение перед помещением в клетку"
L.OPTIONS_CAGE_WINDOW = "Показывать окно списка для клетки"
L.OPTIONS_CAGE_ONCE = "Помещать в клетку только 1 шт. каждого питомца"
L.OPTIONS_CAGE_AMMOUNT = "Сколько питомцев помещать в клетку"
L.OPTIONS_SKIP_CAGED = "Пропускать уже изученных (помещённых в клетку) питомцев"
L.OPTIONS_INCOMPLETE_LIST = "Что делать с прерванным списком авто-клетки"
L.OPTIONS_INCOMPLETE_LIST_1 = "Создать новый список"
L.OPTIONS_INCOMPLETE_LIST_2 = "Продолжить старый список"
L.OPTIONS_INCOMPLETE_LIST_3 = "Спрашивать"
L.OPTIONS_FAVORITE_LIST = "Как обрабатывать избранных питомцев"
L.OPTIONS_CAGE_MAX_LEVEL = "Максимальный уровень для клетки"
L.OPTIONS_CAGE_MAX_LEVEL_TOOLTIP = "Пропускает питомцев выше этого уровня"
L.OPTIONS_CAGE_MIN_LEVEL = "Минимальный уровень для клетки"
L.OPTIONS_CAGE_MIN_LEVEL_TOOLTIP = "Пропускает питомцев ниже этого уровня"
L.OPTIONS_CAGE_MAX_QUANTITY = "Помещать в клетку только при количестве ≥"
L.OPTIONS_CAGE_MAX_QUANTITY_TOOLTIP = "Пропускает питомца, если изучено меньше указанного количества"
L.OPTIONS_SKIP_AUCTION = "Пропускать питомцев, которые есть на аукционе у текущего персонажа (требуется TSM)"
L.OPTIONS_SKIP_AUCTION_MATCHING = "Пропускать только аукционы с таким же уровнем (требуется TSM)"
L.OPTIONS_CAGE_MAX_PRICE = "Помещать в клетку только дороже определённой цены (требуется TSM)"
L.OPTIONS_CAGE_MAX_PRICE_VALUE = "Золота"
L.OPTIONS_CAGE_MAX_PRICE_VALUE_TOOLTIP = "Верхний лимит цены для фильтра."
L.OPTIONS_HANDLE_PETWHITELIST = "Как обрабатывать пользовательский список питомцев"
L.OPTIONS_HANDLE_PETWHITELIST_TOOLTIP = "Этот список всегда добавляется и игнорирует любые правила."

L.OPTIONS_PETWHITELIST = "Пользовательский список питомцев"

L.OPTIONS_WHITELLIST_TOOLTIP = "Добавьте питомцев, которых нужно всегда помещать в клетку, |c"..commandColor.."по одному в строку|r. Регистр не важен, но остальные символы должны совпадать. Можно использовать |c"..commandColor.."*|r как подстановочный знак. Этот список игнорирует все правила."
L.OPTIONS_HANDLE_PETBLACKLIST = "Пропускать чёрный список"
L.OPTIONS_PETBLACKLIST = "Чёрный список питомцев"
L.OPTIONS_BLACKLIST_TOOLTIP = "Добавьте питомцев, которых НЕ нужно помещать в клетку, |c"..commandColor.."по одному в строку|r. Регистр не важен, но остальные символы должны совпадать. Можно использовать |c"..commandColor.."*|r как подстановочный знак."

L.OPTIONS_TSM_HEADER = "Настройки данных TSM"
L.OPTIONS_TSM_VALUE = "Показывать данные TSM (требуется TSM)"
L.OPTIONS_TSM_VALUE_TOOLTIP = "Показывает/скрывает иконку монетки в журнале питомцев"
L.OPTIONS_TSM_DATASOURCE = "Источник цены TSM"
L.OPTIONS_TSM_USE_CUSTOM = "Использовать пользовательский источник TSM"


L.OPTIONS_TSM_CUSTOM_CAGE = "Пользовательский источник TSM - минимальная цена для авто-клетки (не используйте тот же источник, что в разделе TSM Data)"
L.OPTIONS_TSM_CUSTOM_TOOLTIP = "Введите пользовательский источник цены. См. документацию TSM."

L.OPTIONS_TSM_CUSTOM = "Пользовательский источник TSM - отображаемая цена питомца"
L.OPTIONS_TSM_CUSTOM_TOOLTIP = "Введите пользовательский источник цены. См. документацию TSM."
L.OPTIONS_TSM_FILTER = "Фильтровать по цене"
L.OPTIONS_TSM_FILTER_TOOLTIP = "Показывать иконку монетки только если цена выше фильтра."
L.OPTIONS_TSM_RANK = "Менять цвет иконки монетки при достижении % от фильтра"
L.OPTIONS_TSM_RANK_MEDIUM = "Серебро"
L.OPTIONS_TSM_RANK_HIGH = "Золото"

L.CAGED_MESSAGE = "Подходящий питомец - помещаю в клетку!"
L.CAGED_MESSAGE_WHITELIST = "Питомец помещён в клетку (по белому списку)."
L.CAGED_MESSAGE_BLACKLIST = "Питомец пропущен (в чёрном списке)."

L.SLOTTED_PET_MESSAGE = "Питомец в слоте боя - пропущен"
L.HURT_PET_MESSAGE = "Питомец ранен - пропущен"


L.CONTINUE_CAGING_DIALOG_TEXT = "Продолжить помещение старого списка в клетки?"
L.CONTINUE_CAGING_DIALOG_YES = "Да"
L.CONTINUE_CAGING_DIALOG_NO = "Нет"

L.BUILDING_CAGE_LIST = "Формирую список для клетки из %s питомцев"

L.AUTO_CAGE_TOOLTIP_1 = "Поместить в клетки"
L.AUTO_CAGE_TOOLTIP_2 = "Клик: Поместить по правилам"
L.AUTO_CAGE_TOOLTIP_3 = "Shift+Клик: Настройки"

L.FULL_INVENTORY = "Инвентарь заполнен, остановка."

L.KEYBIND_LEARN = "Изучить клеточных питомцев"

L.BUILD_LEARN_LIST = "Формирую список для изучения"
L.LEARN_COMPLETE = "Все возможные питомцы уже изучены."
L.CAGE_COMPLETE  = "Все подходящие питомцы помещены в клетки"

L.BPCM_MOUSEOVER_CAGE = "Поместить в клетку питомца под курсором"

L.TSM_CUSTOM_ERROR = "Неверный пользовательский источник цены: %s"


L.STOP_CAGING_DIALOG_TEXT = "Остановить помещение в клетки?"
L.START_CAGING_DIALOG_TEXT = "Начать помещение в клетки?"

L.LIST_DISPLAY_TEXT = "%s - Уровень: %d %s %s"
L.LIST_DISPLAY_TEXT_PRICE = "- Цена: %s"
L.CAGE_RULES_PRICE_TO_CAGE = "- Цена для клетки: %s"

L.CAGE_RULES_INFO = "- Помещаю до %d шт. питомцев уровней %d–%d, которых у меня ≥ %d шт. %s %s"
L.SKIPPING_RULE = "Пропуск питомцев, уже имеющихся в инвентаре"
L.CAGE_RULES = "Правила помещения в клетку"
L.CAGE_RULES_CUSTOM_TSM = "когда %s больше %s"
L.CAGE_RULES_CUSTOM_PRICE = "стоимостью более %s золота"
L.CAGE_RULES_SKIP = "\n- Пропуск: %s %s %s"
L.CAGE_RULES_SKIP_CAGED = "Уже помещённые в клетку"
L.CAGE_RULES_SKIP_AUCTION = "Выставленные на аукцион"
L.CAGE_RULES_SKIP_BLACKLIST = "В чёрном списке"

L.NO_PETS_TO_CAGE = "Нет подходящих питомцев"
L.OPTIONS_CAGE_QUALITY = "Качество питомцев для помещения в клетку"
L.CAGE_RULES_QUALITY = "\n- Качество: %s%s%s%s"

L.OPTIONS_SHOW_TSM_CUSTOM = "Показывать цену в списке клетки"
