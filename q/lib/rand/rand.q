/#########################
/# Random Data Generator #
/#########################

/ Set random seed (optional)
.util.randSeed[];

// INFO: https://github.com/BuaBook/kdb-common/blob/master/src/rand.q
.rand.typeNulls:-1_.Q.t!rand each("*"^.Q.t)$\:();
/ Sensible default values for random data generation
.rand.typeDefaults:.rand.typeNulls,("hijefcs"!(256h;10000i;1000000j;100e;1000f;" ";`4)),{x!x$\:"p"$.z.d}"pmdznuvt";
.rand.maxListCount:5;

/ @param colNames - sym (list)
/ @param typeLetters - string (list)
/ @param n - number of rows
/ @example - .rand.table[`date`sym`price;"dsE";3]
.rand.table:{[colNames;typeLetters;n]
    colNames,:();
    typeLetters,:();
    if[not all(lowLetters:floor typeLetters)in .Q.t;'.log.error"Column type letters allowed: ",.Q.s1 distinct .Q.t];
    defaults:{[n;letter;lowLetter]
        $[letter in .Q.A;(1+n?.rand.maxListCount);n]?\:.rand.typeDefaults lowLetter
        }[0|n]'[typeLetters;lowLetters];
    flip colNames!defaults};

/ @example - .rand.schema[`date`sym`price;"dse"]
.rand.schema:.rand.table[;;0];
/ @example - .rand.schemaForce[`date`sym`price;"dsE"]
.rand.schemaForce:{[colNames;typeLetters]
    colNames,:();
    typeLetters,:();
    schema:.rand.table[colNames;typeLetters;force:any uppLetters:typeLetters in .Q.A];
    if[force;schema:flip@[schema@-1;colNames where uppLetters|null typeLetters;enlist]];
    schema};

/ Set .rand.typeName functions to generate a random value for the type name
/ @global `.rand.boolean`.rand.guid`.rand.byte`.rand.short`.rand.int`.rand.long`.rand.real`.rand.float`.rand.char`.rand.symbol`.rand.timestamp`.rand.month`.rand.date`.rand.datetime`.rand.timespan`.rand.minute`.rand.second`.rand.time
{name:`$$["c"~x;"char";ssr/[.Q.s1 x$();("`";"$()");("";"")]];
    .rand[name]:{rand y}[;.rand.typeDefaults x];
    }each distinct .Q.t except" ";

/ Generate a random name - "Adjective Name"
/ @return - string
.rand.name:{
    // INFO: https://github.com/moby/moby/blob/master/internal/namesgenerator/names-generator.go
    // INFO: https://github.com/localsend/localsend/blob/main/app/lib/gen/strings_en.g.dart
    adj:rand`Admiring`Adorable`Adoring`Affectionate`Agitated`Amazing`Angry`Awesome`Beautiful`Beautiful`Big`Blissful`Bold`Boring`Brave`Bright`Busy`Charming`Clean`Clever`Clever`Compassionate`Competent`Condescending`Confident`Cool`Cool`Cranky`Crazy`Cunning`Cute`Dazzling`Determined`Determined`Distracted`Dreamy`Eager`Ecstatic`Efficient`Elastic`Elated`Elegant`Eloquent`Energetic`Epic`Exciting`Fantastic`Fast`Fervent`Festive`Fine`Flamboyant`Focused`Fresh`Friendly`Frosty`Funny`Gallant`Gifted`Good`Goofy`Gorgeous`Gracious`Great`Great`Handsome`Happy`Hardcore`Heuristic`Hopeful`Hot`Hungry`Infallible`Inspiring`Intelligent`Interesting`Jolly`Jovial`Keen`Kind`Kind`Laughing`Lovely`Loving`Lucid`Magical`Modest`Musing`Mystic`Mystifying`Naughty`Neat`Nervous`Nice`Nice`Nifty`Nostalgic`Objective`Optimistic`Patient`Peaceful`Pedantic`Pensive`Powerful`Practical`Pretty`Priceless`Quirky`Quizzical`Recursing`Relaxed`Reverent`Rich`Romantic`Sad`Secret`Serene`Sharp`Silly`Sleepy`Smart`Solid`Special`Stoic`Strange`Strategic`Strong`Stupefied`Suspicious`Sweet`Tender`Thirsty`Tidy`Trusting`Unruffled`Upbeat`Vibrant`Vigilant`Vigorous`Wise`Wizardly`Wonderful`Xenodochial`Youthful`Zealous`Zen;
    " "sv string adj,name:rand`Agnesi`Albattani`Allen`Almeida`Antonelli`Apple`Archimedes`Ardinghelli`Aryabhata`Austin`Avocado`Babbage`Banach`Banana`Banzai`Bardeen`Bartik`Bassi`Beaver`Bell`Benz`Bhabha`Bhaskara`Black`Blackberry`Blackburn`Blackwell`Blueberry`Bohr`Booth`Borg`Bose`Bouman`Boyd`Brahmagupta`Brattain`Broccoli`Brown`Buck`Burnell`Cannon`Carrot`Carson`Cartwright`Carver`Cerf`Chandrasekhar`Chaplygin`Chatelet`Chatterjee`Chaum`Chebyshev`Cherry`Clarke`Coconut`Cohen`Colden`Cori`Cray`Curie`Curran`Darwin`Davinci`Dewdney`Dhawan`Diffie`Dijkstra`Dirac`Driscoll`Dubinsky`Easley`Edison`Einstein`Elbakyan`Elgamal`Elion`Ellis`Engelbart`Euclid`Euler`Faraday`Feistel`Fermat`Fermi`Feynman`Franklin`Gagarin`Galileo`Galois`Ganguly`Gates`Gauss`Germain`Goldberg`Goldstine`Goldwasser`Golick`Goodall`Gould`Grape`Greider`Grothendieck`Haibt`Hamilton`Haslett`Hawking`Heisenberg`Hellman`Hermann`Herschel`Hertz`Heyrovsky`Hodgkin`Hofstadter`Hoover`Hopper`Hugle`Hypatia`Ishizaka`Jackson`Jang`Jemison`Jennings`Jepsen`Johnson`Joliot`Jones`Kalam`Kapitsa`Kare`Keldysh`Keller`Kepler`Khayyam`Khorana`Kilby`Kirch`Knuth`Kowalevski`Lalande`Lamarr`Lamport`Leakey`Leavitt`Lederberg`Lehmann`Lemon`Lettuce`Lewin`Lichterman`Liskov`Lovelace`Lumiere`Mahavira`Mango`Margulis`Matsumoto`Maxwell`Mayer`Mccarthy`Mcclintock`Mclaren`Mclean`Mcnulty`Meitner`Melon`Mendel`Mendeleev`Meninsky`Merkle`Mestorf`Mirzakhani`Montalcini`Moore`Morse`Moser`Murdock`Mushroom`Napier`Nash`Neumann`Newton`Nightingale`Nobel`Noether`Northcutt`Noyce`Onion`Orange`Panini`Papaya`Pare`Pascal`Pasteur`Payne`Peach`Pear`Perlman`Pike`Pineapple`Poincare`Poitras`Potato`Proskuriakova`Ptolemy`Pumpkin`Raman`Ramanujan`Raspberry`Rhodes`Ride`Ritchie`Robinson`Roentgen`Rosalind`Rubin`Saha`Sammet`Sanderson`Satoshi`Shamir`Shannon`Shaw`Shirley`Shockley`Shtern`Sinoussi`Snyder`Solomon`Spence`Stonebraker`Strawberry`Sutherland`Swanson`Swartz`Swirles`Taussig`Tesla`Tharp`Thompson`Tomato`Torvalds`Tu`Turing`Varahamihira`Vaughan`Villani`Visvesvaraya`Volhard`Wescoff`Wilbur`Wiles`Williams`Williamson`Wilson`Wing`Wozniak`Wright`Wu`Yalow`Yonath`Zhukovsky
    };
