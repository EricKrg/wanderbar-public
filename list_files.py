from os import listdir
from os.path import isfile, join

all = "/Users/eric/app/wanderbar-public/wanderbar-public/assets/icons"
amazon = all + "/amazon"
dino = all + "/dinosaur"
farming = all + "/farming"
garden = all + "/gardening"
movie = all + "/movie"
pirate = all + "/pirate"
usa = all + "/usa"
survive= all + "/survive"
summer = all + "/summer-holiday"
season = all + "/season"
pirate = all + "/pirate"
medival = all + "/medieval"
japan = all + "/japan"
forest = all + "/forest"


svgs = [forest,survive,amazon, season, dino, farming,garden,medival,japan,usa,movie,pirate,summer]

all_set = set()
all_list = []

for svg_set in svgs:
    print(f"SVGS ${svg_set}")
    for file in listdir(svg_set):
        if isfile(join(svg_set, file)):
            if (file not in all_list):
                all_list.append(file)


print(all_list)