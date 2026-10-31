import 'package:flutter/material.dart';

import '../models/game_models.dart';

const String introText =
    'Halloween-Nacht. Du bist Mina Moderschein, Geisterjägerin im Praktikum. '
    'Im Spukhaus Knarz Manor spukt es heute ausgerechnet nicht. '
    'Finde heraus, warum.';

final Map<String, SceneData> scenes = {
  'garden': const SceneData(
    id: 'garden',
    name: 'Vorgarten',
    skyTop: Color(0xFF1A0B2E),
    skyBottom: Color(0xFF4A2A6B),
    ground: Color(0xFF1E2A1A),
    hasMoon: true,
  ),
  'halle': const SceneData(
    id: 'halle',
    name: 'Eingangshalle',
    skyTop: Color(0xFF2B1B14),
    skyBottom: Color(0xFF4A3025),
    ground: Color(0xFF1C1210),
  ),
  'kueche': const SceneData(
    id: 'kueche',
    name: 'Küche',
    skyTop: Color(0xFF16261F),
    skyBottom: Color(0xFF2C4A3B),
    ground: Color(0xFF121C17),
  ),
};

final Map<String, GameItem> items = {
  'schere': const GameItem(
    id: 'schere',
    name: 'Gartenschere',
    emoji: '✂️',
    description: 'Eine scharfe Gartenschere. Perfekt gegen Hecken, Dornen und Ordnungsämter.',
  ),
  'knopf': const GameItem(
    id: 'knopf',
    name: 'Messingknopf',
    emoji: '🔘',
    description: 'Ein großer, glänzender Messingknopf. Jemand vermisst ihn sicher. Oder auch nicht.',
  ),
  'schluessel': const GameItem(
    id: 'schluessel',
    name: 'Rostiger Schlüssel',
    emoji: '🗝️',
    description: 'Ein Schlüssel, so rostig, dass er beim Anschauen quietscht.',
  ),
  'streichhoelzer': const GameItem(
    id: 'streichhoelzer',
    name: 'Streichhölzer',
    emoji: '🔥',
    description: 'Eine Schachtel Streichhölzer. Zwei Stück sind noch drin.',
  ),
  'kerze': const GameItem(
    id: 'kerze',
    name: 'Kerzenstummel',
    emoji: '🕯️',
    description: 'Ein Kerzenstummel mit Wachsnasen. Er hat schon bessere Zeiten gesehen.',
  ),
  'kelle': const GameItem(
    id: 'kelle',
    name: 'Schöpfkelle',
    emoji: '🥄',
    description: 'Eine große Schöpfkelle. Riecht leicht nach Hexensuppe.',
  ),
  'kette': const GameItem(
    id: 'kette',
    name: 'Rasselkette',
    emoji: '⛓️',
    description: 'Eine klassische Geisterkette, triefend vor Suppe. Sie rasselt noch ein bisschen.',
  ),
};

final List<Hotspot> hotspots = [
  // --- Vorgarten ---
  const Hotspot(
    id: 'tuer',
    scene: 'garden',
    label: 'Haustür',
    emoji: '🚪',
    x: 0.50,
    y: 0.42,
    lookText: 'Eine schwere Eichentür mit einem Fledermaus-Klopfer.',
  ),
  const Hotspot(
    id: 'rabe',
    scene: 'garden',
    label: 'Rabe Edgar',
    emoji: '🐦‍⬛',
    x: 0.82,
    y: 0.55,
    lookText: 'Rabe Edgar hockt auf dem Briefkasten und mustert alles Glänzende wie ein Zollbeamter.',
  ),
  const Hotspot(
    id: 'hecke',
    scene: 'garden',
    label: 'Dornenhecke',
    emoji: '🌳',
    x: 0.70,
    y: 0.80,
    lookText: 'Eine wild wuchernde Dornenhecke. Irgendetwas Glänzendes blitzt zwischen den Zweigen.',
  ),
  const Hotspot(
    id: 'kuerbis',
    scene: 'garden',
    label: 'Riesenkürbis',
    emoji: '🎃',
    x: 0.15,
    y: 0.75,
    lookText: 'Ein riesiger Kürbis mit schiefem Grinsen. Er hat dir gerade zugezwinkert. Bestimmt Einbildung.',
  ),
  const Hotspot(
    id: 'schere',
    scene: 'garden',
    label: 'Gartenschere',
    emoji: '✂️',
    x: 0.33,
    y: 0.85,
    lookText: 'Eine Gartenschere, neben einem Grabstein im Beet vergessen.',
    hiddenByFlag: 'got_schere',
  ),

  // --- Eingangshalle ---
  const Hotspot(
    id: 'treppe',
    scene: 'halle',
    label: 'Treppe',
    emoji: '🪜',
    x: 0.15,
    y: 0.45,
    lookText: 'Die Treppe nach oben ist komplett zugesponnen. Das hat Zeit bis nach Halloween.',
  ),
  const Hotspot(
    id: 'kandelaber',
    scene: 'halle',
    label: 'Kandelaber',
    emoji: '🕯️',
    x: 0.35,
    y: 0.60,
    lookText: 'Ein Kandelaber mit einem einzigen, leeren Kerzenhalter.',
  ),
  const Hotspot(
    id: 'streichhoelzer',
    scene: 'halle',
    label: 'Streichhölzer',
    emoji: '📦',
    x: 0.52,
    y: 0.80,
    lookText: 'Eine Streichholzschachtel auf dem Kaminsims. „Zündend seit 1802“ steht darauf.',
    hiddenByFlag: 'got_streich',
  ),
  const Hotspot(
    id: 'knarz',
    scene: 'halle',
    label: 'Herr von Knarz',
    emoji: '👻',
    x: 0.70,
    y: 0.45,
    lookText: 'Ein durchscheinender Herr in Frack und Pantoffeln. Ihm fehlt sichtlich etwas.',
    requiresFlag: 'halle_hell',
  ),
  const Hotspot(
    id: 'kuechentuer',
    scene: 'halle',
    label: 'Zur Küche',
    emoji: '🚪',
    x: 0.88,
    y: 0.62,
    lookText: 'Eine Schwingtür zur Küche. Dahinter blubbert es verdächtig.',
  ),
  const Hotspot(
    id: 'ausgang',
    scene: 'halle',
    label: 'Zum Garten',
    emoji: '🚪',
    x: 0.12,
    y: 0.82,
    lookText: 'Die Haustür von innen. Dahinter wartet der Garten.',
  ),

  // --- Küche ---
  const Hotspot(
    id: 'kessel',
    scene: 'kueche',
    label: 'Hexenkessel',
    emoji: '🍲',
    x: 0.50,
    y: 0.65,
    lookText: 'Ein Kessel voll grüner Suppe. Am Boden blitzt etwas Metallisches.',
  ),
  const Hotspot(
    id: 'kelle',
    scene: 'kueche',
    label: 'Schöpfkelle',
    emoji: '🥄',
    x: 0.25,
    y: 0.45,
    lookText: 'Eine große Schöpfkelle am Haken.',
    hiddenByFlag: 'got_kelle',
  ),
  const Hotspot(
    id: 'kerze',
    scene: 'kueche',
    label: 'Kerzenstummel',
    emoji: '🕯️',
    x: 0.75,
    y: 0.50,
    lookText: 'Ein Kerzenstummel auf dem Küchentisch.',
    hiddenByFlag: 'got_kerze',
  ),
  const Hotspot(
    id: 'spinne',
    scene: 'kueche',
    label: 'Spinne Gerda',
    emoji: '🕷️',
    x: 0.82,
    y: 0.22,
    lookText: 'Spinne Gerda strickt an etwas. Es sieht aus wie ein Pullover für acht Arme.',
  ),
  const Hotspot(
    id: 'zurueck',
    scene: 'kueche',
    label: 'Zur Halle',
    emoji: '🚪',
    x: 0.12,
    y: 0.80,
    lookText: 'Die Schwingtür zurück in die Eingangshalle.',
  ),
];

final List<Interaction> interactions = [
  // --- Vorgarten ---
  const Interaction(
    hotspot: 'schere',
    verb: Verb.take,
    giveItem: 'schere',
    setFlag: 'got_schere',
    text: 'Du schnappst dir die Gartenschere. Sie ist erstaunlich scharf für etwas, das neben einem Grabstein lag.',
  ),
  const Interaction(
    hotspot: 'hecke',
    item: 'schere',
    requiresNotFlag: 'got_knopf',
    giveItem: 'knopf',
    setFlag: 'got_knopf',
    text: 'Schnipp, schnapp! Zwischen den Zweigen glitzert ein großer Messingknopf. Er gehört jetzt dir. Ihr beide wisst es.',
  ),
  const Interaction(
    hotspot: 'hecke',
    item: 'schere',
    requiresFlag: 'got_knopf',
    text: 'Die Hecke ist jetzt ordentlich frisiert. Mehr geht nicht.',
  ),
  const Interaction(
    hotspot: 'hecke',
    verb: Verb.take,
    text: 'Du pikst dich an den Dornen. Mit einem Werkzeug ginge das besser.',
  ),
  const Interaction(
    hotspot: 'rabe',
    verb: Verb.talk,
    startDialog: 'rabe_start',
    text: 'Edgar legt den Kopf schief.',
  ),
  const Interaction(
    hotspot: 'rabe',
    verb: Verb.take,
    text: 'Edgar plustert sich auf wie ein Federkissen mit Gewaltproblem. Du lässt es lieber.',
  ),
  const Interaction(
    hotspot: 'rabe',
    item: 'knopf',
    consumeItem: true,
    giveItem: 'schluessel',
    setFlag: 'rabe_zufrieden',
    text: 'Edgar schnappt den Knopf, gurgelt vor Glück und lässt einen Rostigen Schlüssel fallen. „Geschäft ist Geschäft“, krächzt er.',
  ),
  const Interaction(
    hotspot: 'tuer',
    item: 'schluessel',
    requiresNotFlag: 'tuer_offen',
    consumeItem: true,
    setFlag: 'tuer_offen',
    text: 'Klick! Die Tür öffnet sich mit einem Quietschen, das Fledermäuse in Rente schickt.',
  ),
  const Interaction(
    hotspot: 'tuer',
    requiresFlag: 'tuer_offen',
    gotoScene: 'halle',
    text: 'Du betrittst die Eingangshalle. Es ist stockfinster. Irgendwo tropft etwas, hoffentlich Wasser.',
  ),
  const Interaction(
    hotspot: 'tuer',
    requiresNotFlag: 'tuer_offen',
    text: 'Verschlossen. Die Tür sieht aus, als würde sie dich dafür auslachen.',
  ),
  const Interaction(
    hotspot: 'kuerbis',
    verb: Verb.talk,
    text: 'Der Kürbis schweigt beharrlich. Typisch Gemüse.',
  ),
  const Interaction(
    hotspot: 'kuerbis',
    verb: Verb.take,
    text: 'Viel zu schwer. Und er grinst dabei.',
  ),

  // --- Eingangshalle ---
  const Interaction(
    hotspot: 'streichhoelzer',
    verb: Verb.take,
    giveItem: 'streichhoelzer',
    setFlag: 'got_streich',
    text: 'Streichhölzer! Auf der Schachtel steht „Zündend seit 1802“. Das Versprechen ist mutig.',
  ),
  const Interaction(
    hotspot: 'kandelaber',
    item: 'kerze',
    requiresNotFlag: 'kerze_steckt',
    consumeItem: true,
    setFlag: 'kerze_steckt',
    text: 'Du steckst den Kerzenstummel auf den Kandelaber. Jetzt fehlt nur noch Feuer.',
  ),
  const Interaction(
    hotspot: 'kandelaber',
    item: 'streichhoelzer',
    requiresFlag: 'kerze_steckt',
    requiresNotFlag: 'halle_hell',
    consumeItem: true,
    setFlag: 'halle_hell',
    text: 'Fffsch! Warmes Licht füllt die Halle. In der Ecke wird ein Geist sichtbar, der verlegen hüstelt.',
  ),
  const Interaction(
    hotspot: 'kandelaber',
    item: 'streichhoelzer',
    requiresNotFlag: 'kerze_steckt',
    text: 'Du hast nichts zum Anzünden. Der Kandelaber wirkt enttäuscht.',
  ),
  const Interaction(
    hotspot: 'knarz',
    verb: Verb.talk,
    startDialog: 'knarz_start',
    text: 'Der Geist richtet seinen durchscheinenden Kragen.',
  ),
  const Interaction(
    hotspot: 'knarz',
    item: 'kette',
    consumeItem: true,
    setFlag: 'ende',
    ends: true,
    text: 'Herr von Knarz greift sich die Rasselkette, drückt sie gerührt an die Brust und lässt sie dann so laut scheppern, dass im ganzen Haus die Türen klappern. '
        'Es rasselt, es heult, es spukt, endlich! Draußen schlägt die Turmuhr Mitternacht, und im Garten fängt der Kürbis an zu singen. '
        'Frohes Halloween, Mina!',
  ),
  const Interaction(
    hotspot: 'kuechentuer',
    gotoScene: 'kueche',
    text: 'Du betrittst die Küche. Es riecht nach Suppe und schlechten Entscheidungen.',
  ),
  const Interaction(
    hotspot: 'ausgang',
    gotoScene: 'garden',
    text: 'Du trittst zurück in den Garten. Der Mond starrt dich an.',
  ),

  // --- Küche ---
  const Interaction(
    hotspot: 'kerze',
    verb: Verb.take,
    giveItem: 'kerze',
    setFlag: 'got_kerze',
    text: 'Du steckst den Kerzenstummel ein. Er tropft dir auf den Stiefel. Frechheit.',
  ),
  const Interaction(
    hotspot: 'kelle',
    verb: Verb.take,
    giveItem: 'kelle',
    setFlag: 'got_kelle',
    text: 'Du hängst die Schöpfkelle vom Haken. Sie klappert zufrieden.',
  ),
  const Interaction(
    hotspot: 'kessel',
    item: 'kelle',
    requiresNotFlag: 'got_kette',
    giveItem: 'kette',
    setFlag: 'got_kette',
    text: 'Du fischst in der grünen Suppe und ziehst eine Rasselkette heraus. Sie riecht nach Lauch. Und nach 1789.',
  ),
  const Interaction(
    hotspot: 'kessel',
    verb: Verb.take,
    text: 'Heiß. Grün. Nein.',
  ),
  const Interaction(
    hotspot: 'kessel',
    verb: Verb.talk,
    text: 'Die Suppe blubbert beleidigt.',
  ),
  const Interaction(
    hotspot: 'spinne',
    verb: Verb.talk,
    text: 'Gerda winkt mit drei Beinen. Die anderen fünf sind beschäftigt.',
  ),
  const Interaction(
    hotspot: 'zurueck',
    gotoScene: 'halle',
    text: 'Du gehst zurück in die Eingangshalle.',
  ),
];

final Map<String, DialogNode> dialogs = {
  'rabe_start': const DialogNode(
    speaker: 'Rabe Edgar',
    line: 'Krah! Du siehst aus wie jemand, der Dinge sucht. Ich sehe aus wie jemand, der Dinge hat.',
    options: [
      DialogOption(text: 'Hast du einen Schlüssel?', next: 'rabe_schluessel'),
      DialogOption(text: 'Was magst du eigentlich?', next: 'rabe_mag'),
      DialogOption(text: 'Tschüss, Edgar.'),
    ],
  ),
  'rabe_schluessel': const DialogNode(
    speaker: 'Rabe Edgar',
    line: 'Einen Rostigen Schlüssel? Hab ich. Gibt es gegen etwas Glänzendes. Gratis gibt es nur Krächzen.',
    options: [
      DialogOption(text: 'Verstanden.', next: 'rabe_start'),
    ],
  ),
  'rabe_mag': const DialogNode(
    speaker: 'Rabe Edgar',
    line: 'Glänzendes! Münzen, Löffel, Knöpfe. Besonders Knöpfe. Große Knöpfe.',
    options: [
      DialogOption(text: 'Ich schaue mich um.', next: 'rabe_start'),
    ],
  ),
  'knarz_start': const DialogNode(
    speaker: 'Herr von Knarz',
    line: 'Uuuuh... ach, was soll es. Ich bin Herr von Knarz. Ich spuke hier seit 1789, aber seit gestern ohne Rasselkette. Peinlich.',
    options: [
      DialogOption(text: 'Wo ist deine Kette?', next: 'knarz_kette'),
      DialogOption(text: 'Kann ich dir helfen?', next: 'knarz_hilfe'),
      DialogOption(text: 'Ich komme später wieder.'),
    ],
  ),
  'knarz_kette': const DialogNode(
    speaker: 'Herr von Knarz',
    line: 'Irgendwo in der Küche verlegt. Beim Suppe-Umrühren, vermute ich. Ein Geist ohne Kette ist wie ein Hund ohne Wau.',
    options: [
      DialogOption(text: 'Ich schaue nach.', next: 'knarz_start'),
    ],
  ),
  'knarz_hilfe': const DialogNode(
    speaker: 'Herr von Knarz',
    line: 'Bring mir die Kette, und ich zeige dir, wie man richtig spukt. Ehrenwort. Ehrenwort eines Toten, immerhin.',
    options: [
      DialogOption(text: 'Abgemacht.', next: 'knarz_start'),
    ],
  ),
};
