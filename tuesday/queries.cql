
CALL gds.graph.project(
    'routes',
    'Airport',
    'HAS_ROUTE'
)
YIELD
    graphName, nodeProjection, nodeCount, relationshipProjection, relationshipCount;

/*
	graphName	nodeProjection	nodeCount	relationshipProjection	relationshipCount
"routes"	

{
  "Airport": {
    "label": "Airport",
    "properties": {

    }
  }
}

	3503	

{
  "HAS_ROUTE": {
    "aggregation": "DEFAULT",
    "orientation": "NATURAL",
    "indexInverse": false,
    "properties": {

    },
    "type": "HAS_ROUTE"
  }
}

	46389
*/


match (n:Airport)-[r:HAS_ROUTE]->(n2:Airport)
return count(r);

/*
count(r)
46389
*/

// Centrality
CALL gds.pageRank.stream('routes')
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS n, score AS pageRank
RETURN n.iata AS iata, n.descr AS description, pageRank
ORDER BY pageRank DESC, iata ASC;

/*
	iata	description	pageRank
"DFW"	"Dallas/Fort Worth International Airport"	11.97978260670334
"ORD"	"Chicago O'Hare International Airport"	11.162988178920267
"DEN"	"Denver International Airport"	10.997299338126387
"ATL"	"Hartsfield - Jackson Atlanta International Airport"	10.389948350302957
"IST"	"Istanbul International Airport"	8.425801217705782
"CDG"	"Paris Charles de Gaulle"	8.401469085296542
"IAH"	"George Bush Intercontinental"	8.34114108524013
"FRA"	"Frankfurt am Main"	8.203204538770196
"LAX"	"Los Angeles International Airport"	8.193558075446688
"CLT"	"Charlotte Douglas International Airport"	7.873302960818332
"AMS"	"Amsterdam Airport Schiphol"	7.812313354381447
*/


// Write pageRank property 

CALL gds.pageRank.write('routes',
    {
        writeProperty: 'pageRank'
    }
)
YIELD nodePropertiesWritten, ranIterations;

/*

nodePropertiesWritten	ranIterations
3503	20
*/

// Show me the airports with pageRank
MATCH (a:Airport)
RETURN a.iata AS iata, a.descr AS description, a.pageRank AS pageRank
ORDER BY a.pageRank DESC, a.iata ASC;

/*

	iata	description	pageRank
"DFW"	"Dallas/Fort Worth International Airport"	11.979782606703338
"ORD"	"Chicago O'Hare International Airport"	11.162988178920267
"DEN"	"Denver International Airport"	10.997299338126384
"ATL"	"Hartsfield - Jackson Atlanta International Airport"	10.389948350302959
"IST"	"Istanbul International Airport"	8.425801217705782
"CDG"	"Paris Charles de Gaulle"	8.401469085296542
"IAH"	"George Bush Intercontinental"	8.34114108524013
"FRA"	"Frankfurt am Main"	8.203204538770196
"LAX"	"Los Angeles International Airport"	8.193558075446687
"CLT"	"Charlotte Douglas International Airport"	7.873302960818332
*/

// Uncovering distinct clusters or communities of nodes, shedding light on cohesive groups or substructures within a graph. 
CALL gds.louvain.stream('routes')
YIELD nodeId, communityId
WITH gds.util.asNode(nodeId) AS n, communityId
RETURN
    communityId,
    SIZE(COLLECT(n)) AS numberOfAirports,
    COLLECT(DISTINCT n.city) AS cities
ORDER BY numberOfAirports DESC, communityId;

/*
╒═══════════╤════════════════╤═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╕
│communityId│numberOfAirports│cities                                                                                                                                                                                                                                                                                                                                                                                                                                                                         │
╞═══════════╪════════════════╪═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╡
│3321       │697             │["Atlanta", "Anchorage", "Austin", "Nashville", "Boston", "Baltimore", "Washington D.C.", "Dallas", "Fort Lauderdale", "Houston", "New York", "Los Angeles", "Orlando", "Miami", "Minneapolis", "Chicago", "West Palm Beach", "Phoenix", "Raleigh", "Seattle", "San Francisco", "San Jose", "Tampa", "San Diego", "Long Beach", "Santa Ana", "Salt Lake City", "Las Vegas", "Denver", "White Plains", "San Antonio", "New Orleans", "Newark", "Cedar Rapids", "Honolulu", "El P│
│           │                │aso", "San Juan", "Cleveland", "Oakland", "Tucson", "Santa Fe", "Philadelphia", "Detroit", "Toronto", "Vancouver", "Ottawa", "Fort Myers", "Montreal", "Edmonton", "Calgary", "St. John's", "Mexico City", "Kingston", "Tallahassee", "Pittsburgh", "Portland", "Oaklahoma City", "Ontario", "Rochester", "Halifax", "Winnipeg", "Charlotte", "Cancun", "Palm Springs", "Memphis", "Cincinnati", "Indianapolis", "Kansas City", "St Louis", "Albuquerque", "Milwaukee", "Harris│
│           │                │on", "Salina", "Omaha", "Tulsa", "Puerto Vallarta", "Kahului", "Nassau", "Freeport", "George Town", "Key West", "Bridgetown", "St. George", "Charlotte Amalie", "Hamilton", "Scarborough", "Port of Spain", "Montego Bay", "Little Rock", "Kralendijk", "Oranjestad", "Norfolk", "Jacksonville", "Providence", "Punta Cana", "Harrisburg", "Sacramento", "Roatan Island", "Tegucigalpa", "Colorado Springs", "Huntsville", "Birmingham", "Quebec City", "Rapid City", "Louisvil│
│           │                │le", "Buffalo", "Shreveport", "Boise", "Lihue", "Lubbock", "Panama City Beach", "Harlingen", "Reno", "Columbus", "Idaho Falls", "Albany", "Wichita", "Midland", "Saskatoon", "Hartford", "Billings", "Sint Martin", "Springfield", "Richmond", "Texarkana", "Peoria", "Hilo", "Lexington", "Guatemala City", "Islip", "Niagara Falls", "Newburgh", "South Bimini", "Havana", "Corpus Christi", "Abilene", "Waco", "College Station", "Bloomington/Normal", "Beaumont/Port Arthu│
│           │                │r", "Des Moines", "Myrtle Beach", "Alexandria", "Cozumel", "Aguascalientes", "Monterrey", "Amarillo", "Silao", "Brownsville", "Baton Rouge", "Belize City", "Columbia", "Chattanooga", "Charleston", "Champaign/Urbana", "Dayton", "Chihuahua", "Durango", "Evansville", "Fargo", "Fresno", "Sioux Falls", "Fort Smith", "Fort Wayne", "Garden City", "Guadalajara", "Longview", "Grand Junction", "Gulfport", "Grand Island", "Fort Hood/Killeen", "Grand Rapids", "Greensboro│
│           │                │", "Greenville", "Jackson", "Joplin", "Lawton", "Lake Charles", "Lafayette", "Liberia", "Laredo", "Mc Allen", "Montgomery", "Manhattan", "Moline", "Morelia", "Monroe", "Mobile", "Madison", "Mazatlán", "Puebla", "Providenciales Island", "Pensacola", "Querétaro", "Roswell", "Santa Clara", "Savannah", "San José del Cabo", "San Angelo", "San Luis Potosí", "Wichita Falls", "Torreón", "Tyler", "Knoxville", "Valparaiso", "Fayetteville/Springdale/", "Zacatecas", "Vie│
│           │                │ux Fort", "Akron", "Burlington", "Manchester", "Syracuse", "Regina", "Florence", "Asheville", "Eagle", "Hayden", "Sarasota/Bradenton", "Topeka", "Lansing", "Roanoke", "Marquette", "Green Bay", "Augusta", "Bangor", "Fayetteville", "Hilton Head Island", "Wilmington", "Puerto Plata", "Holguin", "Varadero", "Aguadilla", "Naples", "Gainesville", "La Romana", "Santo Domingo", "Santiago", "La Mesa", "Mérida", "Managua", "Port-au-Prince", "Cayman Brac", "Georgetown",│
│           │                │ "Marsh Harbour", "North Eleuthera", "Cartagena", "Fort-de-France", "Pointe-à-Pitre Le Raizet", "Saint George's", "Christiansted", "Basseterre", "Burbank", "Samana", "Ponce", "Atlantic City", "Allentown", "Appleton", "Wilkes-Barre/Scranton", "Kalamazoo", "Brunswick", "Charlottesville", "Daytona Beach", "Dothan", "New Bern", "Flint", "Columbus/W Point/Starkville", "Lewisburg", "Saginaw", "Macon", "Meridian", "Melbourne", "Muscle Shoals", "Newport News", "Hatti│
│           │                │esburg/Laurel", "South Bend", "Bristol/Johnson/Kingsport", "Trenton", "Tupelo", "Valdosta", "Lanai City", "Kailua/Kona", "Pago Pago", "Lahaina", "Kaunakakai", "London", "Waterloo", "Sioux City", "Kitchener", "Cayo Coco", "Victoria", "Arcata/Eureka", "Bakersfield", "Crescent City", "Chico", "Eugene", "Klamath Falls", "Medford", "Modesto", "Monterey", "North Bend", "Pasco", "Redding", "Redmond", "Santa Barbara", "San Luis Obispo", "Kelowna", "Aspen", "Bellingha│
│           │                │m", "Carlsbad", "Spokane", "Kingman", "Merced", "Mammoth Lakes", "Yuma", "Prescott", "Santa Maria", "Santa Rosa", "Visalia", "Hermosillo", "Loreto", "Uruapan", "Ixtapa", "Manzanillo", "Provo", "Butte", "Bozeman", "Cedar City", "Moab", "Cody", "Casper", "Elko", "Gillette", "Kalispell", "Great Falls", "Helena", "Lewiston", "Missoula", "Pocatello", "Rock Springs", "St George", "Twin Falls", "Vernal", "Branson", "Fort McMurray", "Alliance", "Alamosa", "Scottsbluf│
│           │                │f", "Bismarck", "Cortez", "Cheyenne", "Dodge City", "Dickinson", "Kearney", "Farmington", "Gunnison", "Williston", "Laramie", "North Platte", "Liberal", "Lincoln", "Mc Cook", "Minot", "Montrose", "Page", "Pierre", "Pueblo", "Riverton", "Sheridan", "Watertown", "Hancock", "Mosinee", "Dubuque", "Decatur", "Duluth", "Eau Claire", "Elmira/Corning", "La Crosse", "Muskegon", "Paducah", "St Cloud", "Toledo", "Traverse City", "State College", "Toluca", "Latrobe", "Wo│
│           │                │rcester", "Plattsburgh", "Treasure Cay", "Governor's Harbour", "San Salvador", "Moncton", "Altoona", "Binghamton", "Beckley", "Hagerstown", "Johnstown", "Lancaster", "Morgantown", "Staunton/Waynesboro/Harrisonburg", "Ithaca", "Grand Forks", "Chicago/Rockford", "Aberdeen", "Alpena", "Bemidji", "Brainerd", "Hibbing", "Iron Mountain / Kingsford", "International Falls", "Rhinelander", "Nantucket", "Bar Harbor", "Hyannis", "Lebanon", "Martha's Vineyard", "Presque │
│           │                │Isle", "Provincetown", "Rockland", "Rutland", "Saranac Lake", "Cold Bay", "Cordova", "Adak Island", "Dillingham", "Kenai", "Homer", "Iliamna", "King Salmon", "Sand Point", "St Mary's", "St Paul Island", "Valdez", "Athens", "Hobbs", "Acapulco", "Huatulco", "Ciudad del Carmen", "Saltillo", "Oaxaca", "Tampico", "Villahermosa", "Veracruz", "Flagstaff", "Show Low", "Silver City", "Sault Ste Marie", "Deer Lake", "Fredericton", "Windsor", "Thunder Bay", "Sydney", "S│
│           │                │udbury", "Saint John", "Timmins", "North Bay", "Charlottetown", "Sarnia", "Camaguey", "Erie", "New Haven", "Williamsport", "Salisbury", "Escanaba", "Pellston", "Bradford", "Dubois", "Franklin", "Jamestown", "Parkersburg", "Imperial", "Trail", "Bella Coola", "Campbell River", "Nanaimo", "Castlegar", "Dawson Creek", "Kamloops", "Prince Rupert", "Powell River", "Comox", "Quesnel", "Williams Lake", "Cranbrook", "Fort St.John", "Prince George", "Terrace", "Whiteho│
│           │                │rse", "Smithers", "Penticton", "Sandspit", "Port Hardy", "Masset", "Walla Walla", "Wenatchee", "St Petersburg-Clearwater", "Pullman/Moscow", "Yakima", "Marigot", "Gustavia", "Culebra Island", "Mayaguez", "Vieques Island", "Charlestown", "The Valley", "Road Town", "Spanish Town", "Stockton", "Punta Gorda", "Baie-Comeau", "Bagotville", "High Level", "Rainbow Lake", "Grande Prairie", "Wabush", "Abbotsford", "Mont-Joli", "Sept-Îles", "Bathurst", "Saint-Pierre", "│
│           │                │Tijuana", "Cayo Largo del Sur", "Fort Nelson", "Culiacán", "Chetumal", "Ciudad Obregón", "Campeche", "Ciudad Juárez", "Ciudad Victoria", "Tepic", "Colima", "Xalapa", "Lázaro Cárdenas", "Los Mochis", "La Paz", "Matamoros", "Mexicali", "Minatitlán", "Nuevo Laredo", "Poza Rica", "Piedras Negras", "Palenque", "Puerto Escondido", "Reynosa", "Tuxtla Gutiérrez", "Tapachula", "Brandon", "Lloydminster", "Red Deer", "Lethbridge", "Medicine Hat", "Chadron", "Levelock", │
│           │                │"Anahim Lake", "St. Anthony", "Charlo", "Fort Hope", "Gaspé", "Îles-de-la-Madeleine", "Havre St-Pierre", "Montréal", "Bella Bella", "Stephenville", "Schefferville", "Natashquan", "Port-Menier", "Gander", "Bonaventure", "Webequie", "Goose Bay", "Kapuskasing", "Churchill Falls", "Belleville", "Cape Girardeau", "Clarksburg", "El Dorado", "New Bedford", "Grand Canyon", "Glendive", "Glasgow", "Huron", "Hot Springs", "Huntington", "Havre", "Kirksville", "Jonesboro"│
│           │                │, "Los Alamos", "Lynchburg", "Manistee", "Morristown", "Massena", "Marion", "Ogdensburg", "Wolf Point", "Owensboro", "Pendleton", "Portsmouth", "Sidney", "Fort Leonard Wood", "Teterboro", "Thief River Falls", "Quincy", "Worland", "Youngstown/Warren", "Cockburn Town", "South Caicos Island", "La Isabela", "San Benito", "La Ceiba", "Puerto Lempira", "Isla Colón", "David", "La Fortuna/San Carlos", "Roxana", "Puntarenas", "Golfito", "Nicoya", "Puerto Jimenez", "Pa│
│           │                │lmar Sur", "Quepos", "Santa Cruz", "Cap Haitien", "Guantánamo", "Little Cayman", "Spring Point", "Arthur's Town", "Colonel Hill", "Rock Sound", "Matthew Town", "Deadman's Cay", "Stella Maris", "Mayaguana", "Port Nelson", "False Pass", "Mountain Village", "Pilot Point", "King Cove", "Yakutat", "Kotlik", "South Naknek", "Sheldon Point", "Castries", "Kingstown", "Igiugig", "Lansdowne House", "St Augustine", "Ogden", "La Romaine", "Ogoki Post", "Chevery", "Lourde│
│           │                │s-De-Blanc-Sablon", "Salt Cay", "Albrook", "Nelson Lagoon", "Kegaska", "Concord", "Hailey", "Everett", "Ceiba"]                                                                                                                                                                                                                                                                                                                                                                │
├───────────┼────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│3275       │520             │["London", "Paris", "Frankfurt", "Helsinki", "Dublin", "Rome", "Amsterdam", "Prague", "Barcelona", "Madrid", "Vienna", "Zurich", "Geneva", "Brussels", "Munich", "Manchester", "Cologne", "Gothenburg", "Venice", "Shannon", "Oslo", "Stockholm", "Nottingham", "Edinburgh", "Glasgow", "Liverpool", "Nice", "Milan", "Athens", "Zagreb", "Budapest", "Alicante", "Bilbao", "Ibiza", "Menorca", "Tenerife", "Larnaca", "Warsaw", "Luqa", "Sofia", "Belgrade", "Tel Aviv", "Hamb│
│           │                │urg", "Stuttgart", "Genoa", "Naples", "Pisa", "Turin", "Bologna", "Verona", "Nantes", "Copenhagen", "Luxembourg", "Dusseldorf", "Lisbon", "Gibraltar", "Tunis", "Reykjavik", "Gran Canaria", "Southampton", "Palma De Mallorca", "Riga", "Malaga", "Funchal", "Leeds", "Aberdeen", "Antalya", "Saint Helier", "Zakynthos", "Rhodes", "Bristol", "Newcastle", "Saint Peter Port", "Eindhoven", "Sevilla", "Basle", "Dubrovnik", "Stavanger", "Bergen", "Tallinn", "Algiers", "Co│
│           │                │rk", "Wroclaw", "Split", "Belfast", "Hannover", "Lyon", "Marseille", "Bucharest", "Rotterdam", "Casablanca", "Tangier", "Faro", "Mykonos Island", "Santorini Island", "Kiev", "Rijeka", "Toulouse/Blagnac", "Porto", "Culleredo", "Innsbruck", "Birmingham", "Inverness", "Salzburg", "Kos Island", "Trondheim", "Billund", "Bern", "Castletown", "Granada", "Firenze", "Dresden", "Deauville", "Brive", "Brest/Guipavas", "Antwerp", "Bremen", "Clermont-Ferrand/Auvergne", "P│
│           │                │rishtina", "Hassi Messaoud", "Erfurt", "Newquay", "Charleston", "Aalborg", "Ålesund", "Torp", "Kraków", "Kaunas", "Fuerteventura Island", "Lanzarote Island", "Tenerife Island", "Agadir", "Marrakech", "Espargos", "Rabil", "Hurghada", "Sharm el-Sheikh", "Tirana", "Paphos", "Almería", "San Javier", "Santiago de Compostela", "Valencia", "Bordeaux/Mérignac", "Bastia/Poretta", "Ajaccio/Napoléon Bonaparte", "Montpellier/Méditerranée", "Strasbourg", "Heraklion", "Kef│
│           │                │allinia Island", "Kalamata", "Kerkyra Island", "Preveza/Lefkada", "Souda", "Thessaloniki", "Bari", "Catania", "Palermo", "Olbia", "İzmir", "Dalaman", "Bodrum", "Istanbul", "Tivat", "Enfidha", "Dortmund", "Nuremberg", "Leipzig", "Cardiff", "Southend", "Grimsby", "Durham", "Norwich", "Exeter", "Kjevik", "Gdańsk", "Växjö", "Linköping", "Sta Cruz de la Palma, La Palma Island", "Nador", "São Pedro", "Girona", "Chios Island", "Kithira Island", "Samos Island", "Lame│
│           │                │zia Terme", "Ljubljana", "Konya", "Kayseri", "Killarney", "Katowice", "Lublin", "Vilnius", "Burgas", "Reus", "Béziers/Vias", "Varna", "Nîmes/Garons", "Waterford", "Rygge", "Rzeszów", "Pula", "Zadar", "Beauvais/Tillé", "Trapani", "Bergamo", "Roma", "Djerba", "Heringsdorf", "Münster", "Friedrichshafen", "Westerland", "Poznań", "Jerez de la Forntera", "Patras", "Graz", "Linz", "Chişinău", "Podgorica", "Skopje", "Bratislava", "Annabah", "Constantine", "Oran", "Mo│
│           │                │nastir", "Rabat", "Ranón", "Vigo", "Pau/Pyrénées (Uzein)", "Biarritz/Anglet/Bayonne", "Calvi/Sainte-Catherine", "Rennes/Saint-Jacques", "Ostrava", "Kharkiv", "Melilla", "Badajoz", "Logroño", "Pamplona", "Hondarribia", "Santander", "Tarbes/Lourdes/Pyrénées", "Alghero", "Cagliari", "Cluj-Napoca", "Timişoara", "Marsa Alam", "Nea Anchialos", "Klagenfurt am Wörthersee", "Sarajevo", "Iaşi", "Sibiu", "Altenrhein", "Košice", "Lviv", "Lille/Lesquin", "Brindisi", "Luga│
│           │                │no", "Marina  Di Campo", "Banja Luka", "Limoges/Bellegarde", "Metz / Nancy", "Figari Sud-Corse", "Caen/Carpiquet", "Hahn", "Memmingen", "Bournemouth", "Blackpool", "Donegal", "Bydgoszcz", "Goleniow", "La Rochelle/Île de Ré", "Rodez/Marcillac", "Carcassonne/Salvaza", "Perpignan/Rivesaltes", "Tours/Val de Loire (Loire Valley)", "Comiso", "Tartu", "Ivalo", "Joensuu / Liperi", "Jyväskylän Maalaiskunta", "Kemi / Tornio", "Kajaani", "Kokkola / Kruunupyy", "Kuusamo"│
│           │                │, "Kuopio / Siilinjärvi", "Mariehamn", "Oulu / Oulunsalo", "Pori", "Rovaniemi", "Savonlinna", "Tampere / Pirkkala", "Turku", "Vaasa", "Norrköping", "Paderborn", "Weeze", "Derry", "Campbeltown", "Lerwick", "Wick", "Port Ellen", "Balivanich", "Stornoway", "Eoligarry", "Balemartine", "Stockholm / Nyköping", "Rostock", "Fes", "Oujda", "Burgos", "León", "Salamanca", "Valladolid", "Bergerac/Roumanière", "Poitiers/Biard", "Karpathos Island", "Kavala", "Mytilene", "L│
│           │                │ampedusa", "Pantelleria", "Reggio Calabria", "Trieste", "Ancona", "Eskişehir", "Bolzano", "Aarhus", "Førde", "Brønnøy", "Målselv", "Evenes", "Leirin", "Florø", "Karmøy", "Kvernberget", "Årø", "Ørland", "Ørsta", "Røros", "Sandane", "Sogndal", "Leirvik", "Alstahaug", "Palanga", "Baden-Baden", "Dundee", "Malmö", "Skellefteå", "Stockholm / Västerås", "Plovdiv", "Osijek", "Zaragoza", "Dinard/Pleurtuit/Saint-Malo", "Toulon/Hyères/Le Palyvestre", "Pescara", "Parma",│
│           │                │ "Perugia", "Brno", "Sundsvall/ Härnösand", "Borlange", "Ronneby", "Jönköping", "Mora", "Kristianstad", "Kalmar", "Halmstad", "Sveg", "Gällivare", "Kramfors / Sollefteå", "Lycksele", "Örnsköldsvik", "Kiruna", "Umeå", "Östersund", "Hagfors", "Karlstad", "Luleå", "Visby", "Ängelholm", "Kittila", "Béjaïa", "Sétif", "Batna", "Tlemcen", "Biskra", "Essaouira", "Ouarzazate", "Agen/La Garenne", "Périgueux/Bassillac", "Castres/Mazamet", "Le Puy/Loudes", "Aurillac", "L│
│           │                │orient/Lann/Bihoué", "Lannion", "Quimper/Pluguffan", "Liège", "Ostend", "Saarbrücken", "Lübeck", "Zweibrücken", "Kassel", "Doncaster", "Maastricht", "Groningen", "Lleida", "Dole/Tavaux", "Alexandroupolis", "Ikaria Island", "Ioannina", "Kastoria", "Kastelorizo Island", "Kalymnos Island", "Kozani", "Leros Island", "Limnos Island", "Milos Island", "Naxos Island", "Paros Island", "Astypalaia Island", "Skiathos", "Syros Island", "Crete Island", "Skiros Island", "V│
│           │                │ila Baleira", "Djanet", "Mecheria", "Tébessi", "Hassi R'Mel", "Tiaret", "Chlef", "Béchar", "Mascara", "El Bayadh", "Adrar", "Ghardaïa", "In Salah", "Touggourt", "Guemar", "Ouargla", "Aménas", "Mannheim", "Augsburg", "Kuressaare", "Lappeenranta", "Staverton", "St. Mary's", "Saint Anne", "Hawarden", "Angelsey", "Esbjerg", "Karup", "Rønne", "Sønderborg", "Vagar", "Geiteryggen", "Trollhättan", "Arvidsjaur", "Örebro", "Torsby", "Pajala", "Alajero, La Gomera Island│
│           │                │", "El Hierro Island", "Dakhla", "El Aaiún", "Tetuan", "Preguiça", "Brač Island", "Saint-Étienne/Bouthéon", "Avignon/Caumont", "Le Havre/Octeville", "Châlons/Vatry", "Dijon/Longvic", "Kasos Island", "Debrecen", "Cuneo", "Eilat", "Mostar", "Tuzla", "Arad", "Baia Mare", "Constanţa", "Craiova", "Oradea", "Satu Mare", "Târgu Mureş", "Gaziantep", "Sivas", "Zonguldak", "Elazığ", "Goulimime", "Kutaisi", "Al Hoceima", "Tamanrasset", "Land's End", "Haifa", "Nis", "Tan│
│           │                │ Tan", "Zhukovsky", "Szcytno", "Samsun", "Chambéry/Aix-les-Bains", "Grenoble", "Valladolises", "Berlin"]                                                                                                                                                                                                                                                                                                                                                                       │
├───────────┼────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│2784       │379             │["Dubai", "New Delhi", "Mumbai", "Doha", "Calicut", "Hyderabad", "Chennai", "Kolkata", "Bengaluru", "Cape Town", "Johannesburg", "Durban", "Nairobi", "Mombasa", "Cairo", "Addis Ababa", "Kuwait", "Istanbul", "Manama", "Abu Dhabi", "Colombo", "Kathmandu", "Jeddah", "Muscat", "Lagos", "Harare", "Luxor", "Riyadh", "Islamabad", "Amman", "Karachi", "Lahore", "Ashgabat", "Jaipur", "Accra", "Kampala", "Abuja", "Beirut", "Freetown", "Luanda", "Tripoli", "Dhaka", "Sylh│
│           │                │et", "Tehran", "Port Louis", "Mahe Island", "Malé", "Kigali", "Arusha", "Ad Dammam", "Arbil", "Dakar", "Agra", "Khajuraho", "Varanasi", "Mangalore", "Ahmedabad", "Jodhpur", "Pune", "Sharjah", "Aden", "Coimbatore", "Cochin", "Trivandrum", "Tiruchirappally", "Sana'a", "Diu", "Porbandar", "Windhoek", "Ankara", "Lusaka", "Hargeisa", "Berbera", "Djibouti City", "Alexandria", "Port Sudan", "Juba", "Khartoum", "Dar es Salaam", "Gheshm", "Kabul", "Douala", "Cotonou",│
│           │                │ "Ouagadougou", "Abidjan", "Niamey", "Sfax", "Lomé", "Brazzaville", "Pointe Noire", "Bangui", "Yaoundé", "St Denis", "Antananarivo", "Libreville", "N'Djamena", "Kinshasa", "Senou", "Monrovia", "Nouakchott", "Conakry", "Praia", "Visakhapatnam", "Kandahar", "Abha", "Buraidah", "Ha'il", "Medina", "Tabuk", "Ta’if", "Yenbo", "Ahwaz", "Bushehr", "Kish Island", "Bandar Lengeh", "Isfahan", "Bandar Abbas", "Mashhad", "Lar", "Lamerd", "Shiraz", "Tabriz", "Chabahar", "Z│
│           │                │ahedan", "Salalah", "Multan", "Peshawar", "Sialkot", "Baghdad", "Basrah", "Najaf", "Sulaymaniyah", "Riyan", "Vasco da Gama", "Chittagong", "Lucknow", "Sir Bani Yas Island", "Jebel Ali", "Amritsar", "Malabo", "Herat", "Aurangabad", "Vadodara", "Bhopal", "Indore", "Jabalpur", "Naqpur", "Raipur", "Magdalla", "Udaipur", "Siliguri", "Bhubaneswar", "Gorakhpur", "Guwahati", "Dibrugarh", "Patna", "Ranchi", "Allahabad", "Bhuntar", "Chandigarh", "Dehradun", "Kangra", "│
│           │                │Jammu", "Kanpur", "Ludhiana", "Leh", "Srinagar", "Banjul", "Bujumbura", "Donetsk", "Dzaoudzi", "Bhuj", "Bhavnagar", "Hubli", "Jamnagar", "Rajkot", "Gwalior", "Bloemfontain", "East London", "Ellisras", "George", "Hoedspruit", "Kimberley", "Mpumalanga", "Margate", "Port Elizabeth", "Plettenberg Bay", "Phalaborwa", "Pietermaritzburg", "Potgietersrus", "Richards Bay", "Upington", "Mthatha", "Francistown", "Kasane", "Maun", "Gaborone", "Manzini", "Livingstone", "N│
│           │                │dola", "Beira", "Inhambabe", "Maputo", "Nampula", "Pemba / Porto Amelia", "Tete", "Vilanculo", "Bulawayo", "Victoria Falls", "Blantyre", "Lilongwe", "Maseru", "Walvis Bay", "Lubumbashi", "Zanzibar", "São Tomé", "Sirt", "Tobruk", "Benghazi", "Al Bayda", "Misratah", "Bobo Dioulasso", "Tamale", "Kumasi", "Sunyani", "Sekondi-Takoradi", "Uyo", "Asaba", "Benin", "Calabar", "Enegu", "Ibadan", "Ilorin", "Owerri", "Jos", "Kaduna", "Kano", "Port Harcourt", "Sokoto", "Y│
│           │                │ola", "Bata", "Port Mathurin", "Maroua", "N'Gaoundéré", "Garoua", "Chipata", "Kasama", "Mansa", "Mfuwe", "Solwesi", "Moroni", "St Pierre", "Sainte Marie", "Toamasina", "Morondava", "Antsiranana", "Antalaha", "Mahajanga", "Nosy Be", "Maroantsetra", "Sambava", "Tôlanaro", "Tulear", "Mbanza Congo", "Cabinda", "Catumbela", "Ngiva", "Huambo", "Kuito", "Malanje", "Menongue", "Namibe", "Saurimo", "Soyo", "Lubango", "Luena", "Port Gentil", "Chimoio", "Lichinga", "Que│
│           │                │limane", "Praslin Island", "Mbandaka", "Boende", "Kisangani", "Kindu", "Kananga", "Tshikapa", "Mbuji Mayi", "Bissau", "Ziguinchor", "Nouadhibou", "Zouérate", "Vila do Maio", "São Filipe", "Arba Minch", "Axum", "Bahir Dar", "Dire Dawa", "Gambela", "Gondar", "Jijiga", "Jimma", "Makale", "Asosa", "Bosaso", "Mogadishu", "Galkayo", "Assiut", "Sohag", "Aswan", "Asmara", "Eldoret", "Kisumu", "Lodwar", "Malindi", "Wajir", "Ghat", "Kufra", "Ghadames", "Kamembe", "El F│
│           │                │asher", "Geneina", "Nyala", "Mbeya", "Mtwara", "Mwanza", "Arua", "Kasese", "Pakuba", "Nicosia", "Adana", "Kastamonu", "Amasya", "Malatya", "Denizli", "Nevşehir", "Çanakkale", "Kosekoy", "Çorlu", "Diyarbakir", "Erzincan", "Erzurum", "Kars", "Trabzon", "Van", "Batman", "Muş", "Kahramanmaraş", "Agri", "Adıyaman", "Mardin", "Şanlıurfa", "Hatay", "Isparta", "Edremit", "Ubari", "Gombe", "Warri", "Al Ahsa", "Al-Fujairah", "Quetta", "Ta'izz", "Paro", "Semera", "Bukav│
│           │                │u", "Gemena", "Shire Indasilase", "Damascus", "Ras Al Khaimah", "Kannur", "Garowe", "Wa"]                                                                                                                                                                                                                                                                                                                                                                                      │
├───────────┼────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│2838       │253             │["Tokyo", "Singapore", "Hong Kong", "Beijing", "Shanghai", "Kuala Lumpur", "Manila", "Bangkok", "Osaka", "Seoul", "Phnom Penh", "Ho Chi Minh City", "Hagta", "Taipei", "Fukuoka", "Sapporo", "Denpasar", "Jakarta", "Guangzhou", "Phuket", "Nanjing", "Chengdu", "Hanoi", "Kaohsiung City", "Tokoname", "Xiamen", "Hangzhou", "Vladivostok", "Shenzhen", "Hiroshima", "Dili", "Tianjin", "Changsha", "Penang", "Wuhan", "Haikou", "Kunming", "Fuzhou", "Ningbo", "Qingdao", "Ch│
│           │                │ongqing", "Guiyang", "Nanning", "Kagoshima", "Oita", "Kanazawa", "Yonago", "Matsuyama", "Takamatsu", "Niigata", "Sendai", "Jeju City", "Busan", "Naha", "Saipan Island", "Babelthuap Island", "Yangon", "Chiang Mai", "Krabi", "Na Thon (Ko Samui Island)", "Hat Yai", "Da Nang", "Bandar Seri Begawan", "Lapu-Lapu City", "Ulaanbaatar", "Taipa", "Kotamadya Balikpapan", "Kota Kinabalu", "Angeles City", "Kota Baharu", "Iloilo City", "Siem Reap", "Khabarovsk", "Yuzhno-Sa│
│           │                │khalinsk", "Changchun", "Dalian", "Shenyang", "Kuching", "Miri", "Kuantan", "Ipoh", "Langkawi", "Kuala Terengganu", "Kuala Lumpur Subang", "Davao City", "Vientiane", "Surabaya", "Bandung-Java Island", "Mataram", "Kalibo", "Pekanbaru-Sumatra Island", "Palembang-Sumatra Island", "Sukarata(Solo)-Java Island", "Semarang-Java Island", "Ujung Pandang-Celebes Island", "Yogyakarta-Java Island", "Taipei City", "Shirahama", "Kobe", "Obihiro", "Hakodate", "Kushiro", "Ōz│
│           │                │ora", "Nakashibetsu", "Wakkanai", "Ube", "Monbetsu", "Asahikawa / Hokkaidō", "Miyazaki", "Kitakyūshū", "Saga", "Kumamoto", "Nagasaki", "Amami", "Toyama", "Wajima", "Okayama City", "Izumo", "Nankoku", "Tottori", "Tokushima", "Masuda", "Aomori", "Yamagata", "Akita", "Misawa", "Odate", "Shonai", "Hachijojima", "Izu Oshima", "Ishigaki", "Miyako City", "Taichung City", "Tainan City", "Taiyuan", "Jinan", "Xianyang", "Nanchang", "Zhengzhou", "Yantai", "Xuzhou", "San│
│           │                │ya", "Hailar", "Daegu", "Gwangju", "Cheongju", "Pyongyang", "Lanzhou", "Lhasa", "Harbin", "Jiamusi", "Mudanjiang", "Qiqihar", "Yanji", "Ji'an", "Manado-Celebes Island", "Redang", "Shantou", "Lijiang", "Wuxi", "Dongying", "Dandong", "Nantong", "Daqing Shi", "Huai'an", "Qianjiang", "Baishan", "Chifeng", "Changzhi", "Ordos", "Datong", "Erenhot,", "Hohhot", "Baotou", "Tongliao", "Wuhai", "Ulanhot", "Xilinhot", "Yuncheng", "Beihai", "Changde", "Dayong", "Guilin Ci│
│           │                │ty", "Zhuhai", "Liuzhou", "Zhanjiang", "Luoyang", "Xiangfan", "Yichang", "Yinchuan", "Jining", "Xining", "Yan'an", "Yulin", "Zhongwei", "Luxi", "Anqing", "Changzhou", "Fuyang", "Ganzhou", "Jingdezhen", "Jiujiang", "Lianyungang", "Huangyan", "Linyi", "Hefei", "Quanzhou", "Huangshan", "Weifang", "Wuyishan", "Wenzhou", "Yancheng", "Yiwu", "Zhoushan", "Dazhou", "Guangyuan", "Luzhou", "Meixian", "Tangshan", "Mohe", "Baoshan", "Lincang", "Panzhihua", "Foshan", "Bai│
│           │                │se", "Zhangye", "Yichun", "Kolaka/Pomala Tambea-Celebes Island", "Jiagedaqi", "Jinchang", "Chizhou", "Jixi", "Heihe", "Bijie", "Sihanukville", "Ürümqi", "Nha Trang", "Mandalay", "Banjarmasin-Borneo Island", "Senai", "Shijiazhuang", "Mianyang", "Zunyi", "Yangzho", "Medan", "Weihai"]                                                                                                                                                                                     │
├───────────┼────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
*/

// Node similarity
CALL gds.nodeSimilarity.stream('routes')
YIELD node1, node2, similarity
WITH gds.util.asNode(node1) AS n1, gds.util.asNode(node2) AS n2, similarity
RETURN
    n1.iata AS iata,
    n1.city AS city,
    COLLECT({iata:n2.iata, city:n2.city, similarityScore: similarity}) AS similarAirports
ORDER BY city LIMIT 20;

/*

╒═════╤═════════════╤═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╕
│iata │city         │similarAirports                                                                                                                                                                                                                                                                                                                                                                                                                                                                │
╞═════╪═════════════╪═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╡
│"AAL"│"Aalborg"    │[{iata: "KRS", city: "Kjevik", similarityScore: 0.3333333333333333}, {iata: "HAU", city: "Karmøy", similarityScore: 0.2727272727272727}, {iata: "SZZ", city: "Goleniow", similarityScore: 0.2608695652173913}, {iata: "AAR", city: "Aarhus", similarityScore: 0.25}, {iata: "TRF", city: "Torp", similarityScore: 0.24444444444444444}, {iata: "BLL", city: "Billund", similarityScore: 0.23333333333333334}, {iata: "AES", city: "Ålesund", similarityScore: 0.227272727272727│
│     │             │27}, {iata: "GOT", city: "Gothenburg", similarityScore: 0.21875}, {iata: "SVG", city: "Stavanger", similarityScore: 0.21568627450980393}, {iata: "KYA", city: "Konya", similarityScore: 0.21052631578947367}]                                                                                                                                                                                                                                                                  │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"AAR"│"Aarhus"     │[{iata: "AAL", city: "Aalborg", similarityScore: 0.25}, {iata: "GOT", city: "Gothenburg", similarityScore: 0.234375}, {iata: "TLL", city: "Tallinn", similarityScore: 0.22916666666666666}, {iata: "VXO", city: "Växjö", similarityScore: 0.21739130434782608}, {iata: "SVG", city: "Stavanger", similarityScore: 0.21153846153846154}, {iata: "HAU", city: "Karmøy", similarityScore: 0.20833333333333334}, {iata: "KRS", city: "Kjevik", similarityScore: 0.20833333333333334│
│     │             │}, {iata: "OSD", city: "Östersund", similarityScore: 0.2}, {iata: "AOI", city: "Ancona", similarityScore: 0.19230769230769232}, {iata: "XRY", city: "Jerez de la Forntera", similarityScore: 0.1875}]                                                                                                                                                                                                                                                                          │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"YXX"│"Abbotsford" │[{iata: "YQU", city: "Grande Prairie", similarityScore: 0.2857142857142857}, {iata: "YQR", city: "Regina", similarityScore: 0.23529411764705882}, {iata: "YQQ", city: "Comox", similarityScore: 0.2222222222222222}, {iata: "YHM", city: "Hamilton", similarityScore: 0.21052631578947367}, {iata: "YXJ", city: "Fort St.John", similarityScore: 0.2}, {iata: "YXE", city: "Saskatoon", similarityScore: 0.2}, {iata: "YLW", city: "Kelowna", similarityScore: 0.1875}, {iata: │
│     │             │"YXU", city: "London", similarityScore: 0.17647058823529413}, {iata: "YMM", city: "Fort McMurray", similarityScore: 0.16666666666666666}, {iata: "YXS", city: "Prince George", similarityScore: 0.14285714285714285}]                                                                                                                                                                                                                                                          │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"ABR"│"Aberdeen"   │[{iata: "HIB", city: "Hibbing", similarityScore: 1.0}, {iata: "BJI", city: "Bemidji", similarityScore: 1.0}, {iata: "ISN", city: "Williston", similarityScore: 0.5}, {iata: "ATY", city: "Watertown", similarityScore: 0.5}, {iata: "RHI", city: "Rhinelander", similarityScore: 0.5}, {iata: "INL", city: "International Falls", similarityScore: 0.5}, {iata: "APN", city: "Alpena", similarityScore: 0.5}, {iata: "BRD", city: "Brainerd", similarityScore: 0.5}, {iata: "DI│
│     │             │K", city: "Dickinson", similarityScore: 0.5}, {iata: "LSE", city: "La Crosse", similarityScore: 0.3333333333333333}]                                                                                                                                                                                                                                                                                                                                                           │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"ABZ"│"Aberdeen"   │[{iata: "INV", city: "Inverness", similarityScore: 0.3023255813953488}, {iata: "MJV", city: "San Javier", similarityScore: 0.2708333333333333}, {iata: "JER", city: "Saint Helier", similarityScore: 0.25862068965517243}, {iata: "GLA", city: "Glasgow", similarityScore: 0.24528301886792453}, {iata: "NCL", city: "Newcastle", similarityScore: 0.24050632911392406}, {iata: "BHD", city: "Belfast", similarityScore: 0.23529411764705882}, {iata: "GOT", city: "Gothenburg"│
│     │             │, similarityScore: 0.23170731707317074}, {iata: "BLL", city: "Billund", similarityScore: 0.22784810126582278}, {iata: "ORK", city: "Cork", similarityScore: 0.22727272727272727}, {iata: "EDI", city: "Edinburgh", similarityScore: 0.22377622377622378}]                                                                                                                                                                                                                      │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"AHB"│"Abha"       │[{iata: "ELQ", city: "Buraidah", similarityScore: 0.5}, {iata: "YNB", city: "Yenbo", similarityScore: 0.4375}, {iata: "HAS", city: "Ha'il", similarityScore: 0.4}, {iata: "TUU", city: "Tabuk", similarityScore: 0.375}, {iata: "ADE", city: "Aden", similarityScore: 0.36363636363636365}, {iata: "RIY", city: "Riyan", similarityScore: 0.35294117647058826}, {iata: "TIF", city: "Ta’if", similarityScore: 0.3333333333333333}, {iata: "ASM", city: "Asmara", similarityScor│
│     │             │e: 0.3157894736842105}, {iata: "SKT", city: "Sialkot", similarityScore: 0.3}, {iata: "ATZ", city: "Assiut", similarityScore: 0.26666666666666666}]                                                                                                                                                                                                                                                                                                                             │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"ABJ"│"Abidjan"    │[{iata: "BKO", city: "Senou", similarityScore: 0.5}, {iata: "OUA", city: "Ouagadougou", similarityScore: 0.4444444444444444}, {iata: "DKR", city: "Dakar", similarityScore: 0.4}, {iata: "LFW", city: "Lomé", similarityScore: 0.3870967741935484}, {iata: "COO", city: "Cotonou", similarityScore: 0.34375}, {iata: "DLA", city: "Douala", similarityScore: 0.30303030303030304}, {iata: "FNA", city: "Freetown", similarityScore: 0.27586206896551724}, {iata: "ACC", city: "│
│     │             │Accra", similarityScore: 0.2608695652173913}, {iata: "NKC", city: "Nouakchott", similarityScore: 0.25925925925925924}, {iata: "NSI", city: "Yaoundé", similarityScore: 0.25925925925925924}]                                                                                                                                                                                                                                                                                   │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"ABI"│"Abilene"    │[{iata: "ACT", city: "Waco", similarityScore: 1.0}, {iata: "GGG", city: "Longview", similarityScore: 1.0}, {iata: "GCK", city: "Garden City", similarityScore: 1.0}, {iata: "BPT", city: "Beaumont/Port Arthur", similarityScore: 1.0}, {iata: "SPS", city: "Wichita Falls", similarityScore: 1.0}, {iata: "SJT", city: "San Angelo", similarityScore: 1.0}, {iata: "LAW", city: "Lawton", similarityScore: 1.0}, {iata: "JLN", city: "Joplin", similarityScore: 1.0}, {iata: "│
│     │             │TXK", city: "Texarkana", similarityScore: 1.0}, {iata: "LCH", city: "Lake Charles", similarityScore: 0.5}]                                                                                                                                                                                                                                                                                                                                                                     │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"AZI"│"Abu Dhabi"  │[{iata: "XSB", city: "Sir Bani Yas Island", similarityScore: 0.2}, {iata: "BDH", city: "Bandar Lengeh", similarityScore: 0.2}, {iata: "LFM", city: "Lamerd", similarityScore: 0.16666666666666666}, {iata: "BUZ", city: "Bushehr", similarityScore: 0.14285714285714285}, {iata: "KDH", city: "Kandahar", similarityScore: 0.14285714285714285}, {iata: "GSM", city: "Gheshm", similarityScore: 0.125}, {iata: "ZYL", city: "Sylhet", similarityScore: 0.125}, {iata: "LRR", ci│
│     │             │ty: "Lar", similarityScore: 0.1111111111111111}, {iata: "BBO", city: "Berbera", similarityScore: 0.1111111111111111}, {iata: "HAS", city: "Ha'il", similarityScore: 0.1}]                                                                                                                                                                                                                                                                                                      │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"AUH"│"Abu Dhabi"  │[{iata: "DOH", city: "Doha", similarityScore: 0.43781094527363185}, {iata: "MCT", city: "Muscat", similarityScore: 0.4032258064516129}, {iata: "DXB", city: "Dubai", similarityScore: 0.37254901960784315}, {iata: "BOM", city: "Mumbai", similarityScore: 0.3586206896551724}, {iata: "RUH", city: "Riyadh", similarityScore: 0.35172413793103446}, {iata: "BAH", city: "Manama", similarityScore: 0.3448275862068966}, {iata: "JED", city: "Jeddah", similarityScore: 0.34375│
│     │             │}, {iata: "KWI", city: "Kuwait", similarityScore: 0.3308270676691729}, {iata: "DEL", city: "New Delhi", similarityScore: 0.32335329341317365}, {iata: "CAI", city: "Cairo", similarityScore: 0.3197278911564626}]                                                                                                                                                                                                                                                              │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"ABV"│"Abuja"      │[{iata: "LOS", city: "Lagos", similarityScore: 0.3448275862068966}, {iata: "LBV", city: "Libreville", similarityScore: 0.20512820512820512}, {iata: "COO", city: "Cotonou", similarityScore: 0.1951219512195122}, {iata: "DLA", city: "Douala", similarityScore: 0.1951219512195122}, {iata: "ACC", city: "Accra", similarityScore: 0.18518518518518517}, {iata: "OUA", city: "Ouagadougou", similarityScore: 0.18421052631578946}, {iata: "ABJ", city: "Abidjan", similaritySc│
│     │             │ore: 0.14893617021276595}, {iata: "BKO", city: "Senou", similarityScore: 0.14285714285714285}, {iata: "NIM", city: "Niamey", similarityScore: 0.14285714285714285}, {iata: "EBB", city: "Kampala", similarityScore: 0.13953488372093023}]                                                                                                                                                                                                                                      │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"ACA"│"Acapulco"   │[{iata: "OAX", city: "Oaxaca", similarityScore: 0.5833333333333334}, {iata: "AGU", city: "Aguascalientes", similarityScore: 0.5454545454545454}, {iata: "DGO", city: "Durango", similarityScore: 0.5}, {iata: "MZT", city: "Mazatlán", similarityScore: 0.42105263157894735}, {iata: "PBC", city: "Puebla", similarityScore: 0.4166666666666667}, {iata: "ZLO", city: "Manzanillo", similarityScore: 0.4}, {iata: "CUU", city: "Chihuahua", similarityScore: 0.4}, {iata: "CEN"│
│     │             │, city: "Ciudad Obregón", similarityScore: 0.36363636363636365}, {iata: "VER", city: "Veracruz", similarityScore: 0.35714285714285715}, {iata: "ZIH", city: "Ixtapa", similarityScore: 0.35714285714285715}]                                                                                                                                                                                                                                                                   │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"ACC"│"Accra"      │[{iata: "LOS", city: "Lagos", similarityScore: 0.3442622950819672}, {iata: "DKR", city: "Dakar", similarityScore: 0.32}, {iata: "BKO", city: "Senou", similarityScore: 0.2682926829268293}, {iata: "ABJ", city: "Abidjan", similarityScore: 0.2608695652173913}, {iata: "LAD", city: "Luanda", similarityScore: 0.23728813559322035}, {iata: "FNA", city: "Freetown", similarityScore: 0.23684210526315788}, {iata: "LFW", city: "Lomé", similarityScore: 0.23255813953488372},│
│     │             │ {iata: "DLA", city: "Douala", similarityScore: 0.23255813953488372}, {iata: "LBV", city: "Libreville", similarityScore: 0.21428571428571427}, {iata: "COO", city: "Cotonou", similarityScore: 0.20454545454545456}]                                                                                                                                                                                                                                                           │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"DMM"│"Ad Dammam"  │[{iata: "RUH", city: "Riyadh", similarityScore: 0.3854166666666667}, {iata: "MED", city: "Medina", similarityScore: 0.3392857142857143}, {iata: "BAH", city: "Manama", similarityScore: 0.30985915492957744}, {iata: "KWI", city: "Kuwait", similarityScore: 0.29545454545454547}, {iata: "MCT", city: "Muscat", similarityScore: 0.27586206896551724}, {iata: "JED", city: "Jeddah", similarityScore: 0.26666666666666666}, {iata: "SHJ", city: "Sharjah", similarityScore: 0.│
│     │             │25663716814159293}, {iata: "SLL", city: "Salalah", similarityScore: 0.23809523809523808}, {iata: "AHB", city: "Abha", similarityScore: 0.22727272727272727}, {iata: "MUX", city: "Multan", similarityScore: 0.21951219512195122}]                                                                                                                                                                                                                                              │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"ADK"│"Adak Island"│[{iata: "HOM", city: "Homer", similarityScore: 1.0}, {iata: "VDZ", city: "Valdez", similarityScore: 1.0}, {iata: "ILI", city: "Iliamna", similarityScore: 1.0}, {iata: "ENA", city: "Kenai", similarityScore: 1.0}, {iata: "DLG", city: "Dillingham", similarityScore: 0.5}, {iata: "SNP", city: "St Paul Island", similarityScore: 0.5}, {iata: "SDP", city: "Sand Point", similarityScore: 0.5}, {iata: "STG", city: "St George", similarityScore: 0.5}, {iata: "CDV", city: │
│     │             │"Cordova", similarityScore: 0.5}, {iata: "KSM", city: "St Mary's", similarityScore: 0.25}]                                                                                                                                                                                                                                                                                                                                                                                     │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"ADA"│"Adana"      │[{iata: "EZS", city: "Elazığ", similarityScore: 0.4117647058823529}, {iata: "HTY", city: "Hatay", similarityScore: 0.3684210526315789}, {iata: "GZT", city: "Gaziantep", similarityScore: 0.3333333333333333}, {iata: "ASR", city: "Kayseri", similarityScore: 0.3333333333333333}, {iata: "DIY", city: "Diyarbakir", similarityScore: 0.2777777777777778}, {iata: "ECN", city: "Nicosia", similarityScore: 0.25}, {iata: "BGW", city: "Baghdad", similarityScore: 0.2413793103│
│     │             │448276}, {iata: "MQM", city: "Mardin", similarityScore: 0.23529411764705882}, {iata: "GNY", city: "Şanlıurfa", similarityScore: 0.23529411764705882}, {iata: "BAL", city: "Batman", similarityScore: 0.23529411764705882}]                                                                                                                                                                                                                                                     │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"ADD"│"Addis Ababa"│[{iata: "NBO", city: "Nairobi", similarityScore: 0.3644067796610169}, {iata: "CAI", city: "Cairo", similarityScore: 0.25}, {iata: "JNB", city: "Johannesburg", similarityScore: 0.22972972972972974}, {iata: "AUH", city: "Abu Dhabi", similarityScore: 0.21604938271604937}, {iata: "DOH", city: "Doha", similarityScore: 0.18143459915611815}, {iata: "DXB", city: "Dubai", similarityScore: 0.17993079584775087}, {iata: "LOS", city: "Lagos", similarityScore: 0.1735537190│
│     │             │0826447}, {iata: "CMN", city: "Casablanca", similarityScore: 0.17261904761904762}, {iata: "CMB", city: "Colombo", similarityScore: 0.168}, {iata: "AMM", city: "Amman", similarityScore: 0.16551724137931034}]                                                                                                                                                                                                                                                                 │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"ADL"│"Adelaide"   │[{iata: "MEL", city: "Melbourne", similarityScore: 0.2823529411764706}, {iata: "PER", city: "Perth", similarityScore: 0.2698412698412698}, {iata: "DRW", city: "Darwin", similarityScore: 0.2127659574468085}, {iata: "OOL", city: "Gold Coast", similarityScore: 0.20454545454545456}, {iata: "SYD", city: "Sydney", similarityScore: 0.20175438596491227}, {iata: "ASP", city: "Alice Springs", similarityScore: 0.19444444444444445}, {iata: "BNE", city: "Brisbane", simila│
│     │             │rityScore: 0.19387755102040816}, {iata: "CBR", city: "Canberra", similarityScore: 0.1891891891891892}, {iata: "CNS", city: "Cairns", similarityScore: 0.1864406779661017}, {iata: "AKL", city: "Auckland", similarityScore: 0.1724137931034483}]                                                                                                                                                                                                                               │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"ADE"│"Aden"       │[{iata: "ELQ", city: "Buraidah", similarityScore: 0.4444444444444444}, {iata: "SAH", city: "Sana'a", similarityScore: 0.39285714285714285}, {iata: "YNB", city: "Yenbo", similarityScore: 0.3888888888888889}, {iata: "TIF", city: "Ta’if", similarityScore: 0.3684210526315789}, {iata: "AHB", city: "Abha", similarityScore: 0.36363636363636365}, {iata: "TUU", city: "Tabuk", similarityScore: 0.3333333333333333}, {iata: "RIY", city: "Riyan", similarityScore: 0.3157894│
│     │             │736842105}, {iata: "IXE", city: "Mangalore", similarityScore: 0.3157894736842105}, {iata: "KRT", city: "Khartoum", similarityScore: 0.30303030303030304}, {iata: "TRV", city: "Trivandrum", similarityScore: 0.2857142857142857}]                                                                                                                                                                                                                                              │
├─────┼─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│"AZR"│"Adrar"      │[{iata: "GHA", city: "Ghardaïa", similarityScore: 0.42857142857142855}, {iata: "HME", city: "Hassi Messaoud", similarityScore: 0.3333333333333333}, {iata: "OGX", city: "Ouargla", similarityScore: 0.2222222222222222}, {iata: "TID", city: "Tiaret", similarityScore: 0.16666666666666666}, {iata: "TEE", city: "Tébessi", similarityScore: 0.16666666666666666}, {iata: "ELU", city: "Guemar", similarityScore: 0.16666666666666666}, {iata: "TGR", city: "Touggourt", simil│
│     │             │arityScore: 0.16666666666666666}, {iata: "MZW", city: "Mecheria", similarityScore: 0.16666666666666666}, {iata: "EBH", city: "El Bayadh", similarityScore: 0.16666666666666666}, {iata: "CBH", city: "Béchar", similarityScore: 0.16666666666666666}]                                                                                                                                                                                                                          │
└─────┴─────────────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

MATCH (src:Airport{iata:"DEN"})-[r1:HAS_ROUTE]->(tmp:Airport)-[r2:HAS_ROUTE]->(dst:Airport{iata: "MEL"})
return r1.distance+r2.distance as distance, src, tmp, dst
order by distance ASC;

/*
distance	src	tmp	dst
8782	

{
  "identity": 8657,
  "labels": [
    "Airport"
  ],
  "properties": {
    "altitude": 5433,
    "descr": "Denver International Airport",
    "pageRank": 10.997299338126384,
    "longest": 16000,
    "iata": "DEN",
    "city": "Denver",
    "icao": "KDEN",
    "location": point({srid:4326, x:-104.672996520996, y:39.8616981506348}),
    "id": "31",
    "pagerank": 10.997299338126387,
    "runways": 6
  },
  "elementId": "4:12bd19d9-cdd0-4e4c-8bab-f35d273a0cac:8657"
}

	

{
  "identity": 8639,
  "labels": [
    "Airport"
  ],
  "properties": {
    "altitude": 127,
    "descr": "Los Angeles International Airport",
    "pageRank": 8.193558075446687,
    "longest": 12091,
    "iata": "LAX",
    "city": "Los Angeles",
    "icao": "KLAX",
    "location": point({srid:4326, x:-118.4079971, y:33.94250107}),
    "id": "13",
    "pagerank": 8.193558075446687,
    "runways": 4
  },
  "elementId": "4:12bd19d9-cdd0-4e4c-8bab-f35d273a0cac:8639"
}

	

{
  "identity": 8683,
  "labels": [
    "Airport"
  ],
  "properties": {
    "altitude": 434,
    "descr": "Melbourne International Airport",
    "pageRank": 3.525257157301838,
    "longest": 11998,
    "iata": "MEL",
    "city": "Melbourne",
    "icao": "YMML",
    "location": point({srid:4326, x:144.843002319336, y:-37.6733016967773}),
    "id": "57",
    "pagerank": 3.525257157301838,
    "runways": 2
  },
  "elementId": "4:12bd19d9-cdd0-4e4c-8bab-f35d273a0cac:8683"
}

8821	

{
  "identity": 8657,
  "labels": [
    "Airport"
  ],
  "properties": {
    "altitude": 5433,
    "descr": "Denver International Airport",
    "pageRank": 10.997299338126384,
    "longest": 16000,
    "iata": "DEN",
    "city": "Denver",
    "icao": "KDEN",
    "location": point({srid:4326, x:-104.672996520996, y:39.8616981506348}),
    "id": "31",
    "pagerank": 10.997299338126387,
    "runways": 6
  },
  "elementId": "4:12bd19d9-cdd0-4e4c-8bab-f35d273a0cac:8657"
}

	

{
  "identity": 8649,
  "labels": [
    "Airport"
  ],
  "properties": {
    "altitude": 13,
    "descr": "San Francisco International Airport",
    "pageRank": 5.743902427552336,
    "longest": 11870,
    "iata": "SFO",
    "city": "San Francisco",
    "icao": "KSFO",
    "location": point({srid:4326, x:-122.375, y:37.6189994812012}),
    "id": "23",
    "pagerank": 5.743902427552337,
    "runways": 4
  },
  "elementId": "4:12bd19d9-cdd0-4e4c-8bab-f35d273a0cac:8649"
}

	

{
  "identity": 8683,
  "labels": [
    "Airport"
  ],
  "properties": {
    "altitude": 434,
    "descr": "Melbourne International Airport",
    "pageRank": 3.525257157301838,
    "longest": 11998,
    "iata": "MEL",
    "city": "Melbourne",
    "icao": "YMML",
    "location": point({srid:4326, x:144.843002319336, y:-37.6733016967773}),
    "id": "57",
    "pagerank": 3.525257157301838,
    "runways": 2
  },
  "elementId": "4:12bd19d9-cdd0-4e4c-8bab-f35d273a0cac:8683"
}
[...]
*/

MATCH (source:Location {name: 'A'})
CALL gds.allShortestPaths.dijkstra.stream('routes-weighted', {
    sourceNode: source,
    relationshipWeightProperty: 'cost'
})
YIELD index, sourceNode, targetNode, totalCost, nodeIds, costs, path
RETURN
    index,
    gds.util.asNode(sourceNode).name AS sourceNodeName,
    gds.util.asNode(targetNode).name AS targetNodeName,
    totalCost,
    [nodeId IN nodeIds | gds.util.asNode(nodeId).name] AS nodeNames,
    costs,
    nodes(path) as path
ORDER BY index


//Creating a weighted graph projection

CALL gds.graph.project(
    'routes-weighted',
    'Airport',
    'HAS_ROUTE',
    {
        relationshipProperties: 'distance'
    }
) YIELD
    graphName, nodeProjection, nodeCount, relationshipProjection, relationshipCount;
RETURN
    index,
    gds.util.asNode(sourceNode).name AS sourceNodeName,
    gds.util.asNode(targetNode).name AS targetNodeName,
    totalCost,
    [nodeId IN nodeIds | gds.util.asNode(nodeId).name] AS nodeNames,
    costs,
    nodes(path) as path
ORDER BY index


///FROM REMI
// Project the graph with distance as a relationship property
CALL gds.graph.project(
  'shortest_routes',
  'Airport',
  {
    HAS_ROUTE: {
      properties: 'distance'
    }
  }
)
YIELD graphName, nodeCount, relationshipCount;

// Find the shortest path from Denver to Melbourne using Dijkstra's algorithm
MATCH (start:Airport {city: 'Denver'}), (end:Airport {city: 'Melbourne'})
CALL gds.shortestPath.dijkstra.stream('shortest_routes', {
  sourceNode: start,
  targetNode: end,
  relationshipWeightProperty: 'distance'
})
YIELD index, sourceNode, targetNode, totalCost, nodeIds, costs, path
RETURN
  [node in gds.util.asNodes(nodeIds) | node.iata] AS airports,
  totalCost,
  path
ORDER BY totalCost ASC
LIMIT 1;


MATCH (n:Crime)-[i:INVESTIGATED_BY]->(o:Officer{surname:"Larive"})
return n LIMIT 10;

/*
{
  "identity": 57116,
  "labels": [
    "Crime"
  ],
  "properties": {
    "date": "25/08/2017",
    "charge": "Possession of Cannabis with Intent to Supply",
    "id": "34f16237cac32a82724094222dd3b92bfe9f415864638071e144154d078d0af8",
    "last_outcome": "Under investigation",
    "type": "Drugs"
  },
  "elementId": "4:c628bfc3-3923-4ff0-97e0-cc4d78e83a08:57116"
}

{
  "identity": 57117,
  "labels": [
    "Crime"
  ],
  "properties": {
    "date": "2/08/2017",
    "charge": "Possession of Cannabis with Intent to Supply",
    "id": "b61be51a27d699f46b6dc7c3ac594783101f5e728f9cf6df898e44fc48021942",
    "last_outcome": "Under investigation",
    "type": "Drugs"
  },
  "elementId": "4:c628bfc3-3923-4ff0-97e0-cc4d78e83a08:57117"
}
[...]
*/

MATCH (n:Crime)-[i:INVESTIGATED_BY]->(o:Officer{surname:"Larive"})
return n, o;




CREATE (u:User {name: "Matéo" });
CREATE (u:User {name: "Adrien" });
CREATE (u:User {name: "Noé" });
CREATE (u:User {name: "Muriel" });
CREATE (u:User {name: "Thomas" });
CREATE (u:User {name: "Vincent" });
CREATE (u:User {name: "Martin" });
CREATE (u:User {name: "Dziyana" });
CREATE (u:User {name: "Charley" });
CREATE (u:User {name: "Rémi" });
CREATE (u:User {name: "Fabien" });
CREATE (u:User {name: "Alexandre" });
CREATE (u:User {name: "Sylvain" });
CREATE (u:User {name: "Mathias" });

CREATE (m:Movie {title: "The Matrix", genre: "Action"});
CREATE (m:Movie {title: "Inception", genre: "Sci-Fi" });
CREATE (m:Movie {title: "The Godfather", genre: "Drama" });
CREATE (m:Movie {title: "Forest Gump", genre: "Drama"});
CREATE (m:Movie {title: "Intersaellar", genre: "Sci-FI" });
CREATE (m:Movie {title: "Mission Impossible", genre: "Action" });
CREATE (m:Movie {title: "La La Land", genre: "Musical" });

MATCH (u:User {name: "Mathias" }), (m:Movie {title: "Inception", genre: "Sci-Fi"})
MERGE (u)-[:LIKES]->(m);

MATCH (u:User {name: "Matéo" }), (m:Movie {title: "The Matrix", genre: "Action"})
MERGE (u)-[:LIKES]->(m);

MATCH (u:User {name: "Alexandre" }), (m:Movie {title: "The Godfather", genre: "Drama"})
MERGE (u)-[:LIKES]->(m);

MATCH (u:User {name: "Rémi" }), (m:Movie {title: "Intersaellar", genre: "Sci-FI" })
MERGE (u)-[:LIKES]->(m);

MATCH (u:User {name: "Thomas" }), (m:Movie {title: "Intersaellar", genre: "Sci-FI" })
MERGE (u)-[:LIKES]->(m);

MATCH (u:User {name: "Noé" }), (m:Movie {title: "Mission Impossible", genre: "Action"})
MERGE (u)-[:LIKES]->(m);

MATCH (u:User {name: "Muriel" }), (m:Movie {title: "Inception", genre: "Sci-Fi"})
MERGE (u)-[:LIKES]->(m);

MATCH (u:User {name: "Sylvain" }), (m:Movie {title: "The Matrix", genre: "Action"})
MERGE (u)-[:LIKES]->(m);

MATCH (u:User {name: "Fabien" }), (m:Movie {title: "Mission Impossible", genre: "Action"})
MERGE (u)-[:LIKES]->(m);

MATCH (u:User {name: "Vincent" }), (m:Movie {title: "Intersaellar", genre: "Sci-FI"})
MERGE (u)-[:LIKES]->(m);

MATCH (u:User { name: 'Martin' }), (m: Movie { title:  'The Matrix', genre: 'Action' })
MERGE (u)-[:LIKES]->(m);

MATCH (u:User {name: "Adrien" }), (m:Movie {title: "Intersaellar", genre: "Sci-FI"})
MERGE (u)-[:LIKES]->(m);

MATCH (u:User {name: "Charley" }), (m:Movie {title: "Intersaellar", genre: "Sci-FI"})
MERGE (u)-[:LIKES]->(m);

MATCH (u:User {name: "Dziyana" }), (m:Movie {title: "The Matrix", genre: "Action"})
MERGE (u)-[:LIKES]->(m);

// Cleaned up version:


CREATE
    (mateo:User {name: "Matéo" }),
    (adrien:User {name: "Adrien" }),
    (noe:User {name: "Noé" }),
    (muriel:User {name: "Muriel" }),
    (thomas:User {name: "Thomas" }),
    (vincent:User {name: "Vincent" }),
    (martin:User {name: "Martin" }),
    (dziyana:User {name: "Dziyana" }),
    (charley:User {name: "Charley" }),
    (remi:User {name: "Rémi" }),
    (fabien:User {name: "Fabien" }),
    (alexandre:User {name: "Alexandre" }),
    (sylvain:User {name: "Sylvain" }),
    (mathias:User {name: "Mathias" }),
    (m0:Movie {title: "The Matrix", genre: "Action"}),
    (m1:Movie {title: "Inception", genre: "Sci-Fi" }),
    (m2:Movie {title: "The Godfather", genre: "Drama" }),
    (m3:Movie {title: "Forest Gump", genre: "Drama"}),
    (m4:Movie {title: "Interstellar", genre: "Sci-Fi" }),
    (m5:Movie {title: "Mission Impossible", genre: "Action" }),
    (m6:Movie {title: "La La Land", genre: "Musical" }),
    (mateo)-[:LIKES]->(m0),
    (alexandre)-[:LIKES]->(m2),
    (remi)-[:LIKES]->(m4),
    (thomas)-[:LIKES]->(m4),
    (noe)-[:LIKES]->(m5),
    (muriel)-[:LIKES]->(m1),
    (mathias)-[:LIKES]->(m1),
    (sylvain)-[:LIKES]->(m0),
    (fabien)-[:LIKES]->(m5),
    (vincent)-[:LIKES]->(m4),
    (martin)-[:LIKES]->(m0),
    (adrien)-[:LIKES]->(m4),
    (charley)-[:LIKES]->(m4),
    (dziyana)-[:LIKES]->(m0);



match (m:Movie)<-[r2:LIKES]-(lu:User)<-[r:FRIENDS_WITH]-(u:User{name:"Muriel"})
where not (m)<-[:LIKES]-(:User{name: "Muriel"})
return m.title, lu.name

match (m:Movie)<-[r2:LIKES]-(lu:User)-[r:FRIENDS_WITH*..3]-(u:User{name:"Dziyana"})
where not (m)<-[:LIKES]-(:User{name: "Dziyana"})
return m.title, lu.name

/*

m.title	lu.name
"Inception"	"Muriel"
"The Grand Budapest Hotel"	"Muriel"
"Inception"	"Mathias"
"Forest Gump"	"Mathias"
"La La Land"	"Mathias"
"The Godfather"	"Alexandre"
*/



match (m:Movie{genre:"Sci-Fi"})
where not (m)<-[:LIKES]-(:User{name:"Vincent"})
return m.title

