#!/bin/sh

# Convert lists of e.g. multi-word names into m4 files that can be used as gazetteers

# EnamexOrg___
./txt2m4.py \
    gaz/gOrgCorpMWordMisc.txt \
    gaz/gOrgCorpMWordFin.txt \
    gaz/gOrgRestaurant.txt \
    gaz/gOrgCorpStore.txt \
    gaz/gOrgAirline.txt \
    gaz/gOrgFashion.txt > gaz/gOrgCorpAll.m4

./txt2m4.py gaz/gOrgMiscFin.txt gaz/gOrgMiscMWord.txt | tr -s ' \n' ' ' | sed 's/. Lst.AlphaUp.*//g' > gaz/gOrgMisc.m4
./txt2m4.py gaz/gOrgMiscFin.txt gaz/gOrgMiscMWord.txt | tr -s ' \n' ' ' | egrep -o 'Lst.AlphaUp.*' > gaz/gOrgMiscFin.m4

./txt2m4.py \
    gaz/gCultInstitution.txt \
    gaz/gCultPerformingGroupFin.txt \
    gaz/gCultPerformingGroupCongr.txt \
    gaz/gCultPerformingGroup.txt | tr -s ' \n' ' ' | sed 's/. Lst.AlphaUp.*//g' > gaz/gOrgCult.m4

./txt2m4.py \
    gaz/gCultInstitution.txt \
    gaz/gCultPerformingGroupFin.txt \
    gaz/gCultPerformingGroupCongr.txt \
    gaz/gCultPerformingGroup.txt | tr -s ' \n' ' ' | egrep -o 'Lst.AlphaUp.*' > gaz/gOrgCultCongr.m4

./txt2m4string.py gaz/gMediaMWord.txt gaz/gMedia1Part.txt > gaz/gOrgMedia.m4   
./txt2m4string.py \
    gaz/gMediaMWordCongr.txt \
    gaz/gMediaMWordFin.txt \
    gaz/gMedia1PartFin.txt > gaz/gOrgMediaFin.m4

./txt2m4.py gaz/gMediaMWordCongr.txt > gaz/gOrgMediaCongr.m4

./txt2m4.py gaz/gOrgAthTeam.txt > gaz/gOrgAthTeam.m4

./txt2m4.py gaz/gOrgParty.txt | tr -s ' \n' ' ' | sed 's/. Lst.AlphaUp.*//g' > gaz/gOrgPartyMisc.m4
./txt2m4.py gaz/gOrgParty.txt | tr -s ' \n' ' ' | egrep -o 'Lst.AlphaUp.*' > gaz/gOrgPartyFin.m4

# EnamexPrs___
./txt2m4.py gaz/gPersMWordMisc.txt gaz/gFictionalFigure.txt > gaz/gPersMWord.m4
./txt2m4.py gaz/gPersMWordFin.txt gaz/gFictionalFigureFin.txt > gaz/gPersMWordFin.m4  

./txt2m4.py \
    gaz/gMythicalBeingFin.txt \
    gaz/gMythicalBeing.txt > gaz/gPersFictional.m4

./txt2m4.py gaz/gAnimalBeast.txt > gaz/gAnimalBeast.m4

# EnamexLoc___
./txt2m4.py gaz/gLocPolMWordMisc.txt \
	    gaz/gLocPolMWordFin.txt | tr -s ' \n' ' ' | sed 's/. Lst.AlphaUp.*//g' > gaz/gLocPolMWord.m4
./txt2m4.py gaz/gLocPolMWordFin.txt | tr -s ' \n' ' ' | egrep -o 'Lst.AlphaUp.*' > gaz/gLocPolMWordFin.m4

./txt2m4.py gaz/gLocPlace.txt gaz/gLocPlaceFin.txt > gaz/gLocPlace.m4

./txt2m4.py gaz/gLocGeoMWordFin.txt | tr -s ' \n' ' ' | sed 's/. Lst.AlphaUp.*//g' > gaz/gLocGeoMWordW.m4
./txt2m4.py gaz/gLocGeoMWordFin.txt | tr -s ' \n' ' ' | egrep -o 'Lst.AlphaUp.*' > gaz/gLocGeoMWordL.m4

./txt2m4.py \
    gaz/gLocFictional.txt \
    gaz/gLocMythical.txt > gaz/gLocFictional.m4

# EnamexPro___
./txt2m4.py gaz/gProdMusic.txt gaz/gArtifact.txt gaz/gProdMisc.txt gaz/gProdArt.txt > gaz/gProdMWord.m4

./txt2m4.py gaz/gProdGame.txt > gaz/gProdGame.m4

./txt2m4.py gaz/gProdVehicleBrand.txt > gaz/gProdVehicleBrand.m4

./txt2m4string.py gaz/gProdVehicleBrand.txt > gaz/gProdVehicleBrandStr.m4

./txt2m4.py gaz/gProdFilmTvMWord.txt gaz/gProdFilmTvMWordFin.txt | tr -s ' \n' ' ' | sed 's/. Lst.AlphaUp.*//g' > gaz/gProdFilmTvMWordW.m4
./txt2m4.py gaz/gProdFilmTvMWord.txt gaz/gProdFilmTvMWordFin.txt | tr -s ' \n' ' ' | egrep -o 'Lst.AlphaUp.*' > gaz/gProdFilmTvMWordL.m4

./txt2m4.py gaz/gProdLitFin.txt > gaz/gProdLitMWord.m4

./txt2m4.py gaz/gProdDrug.txt > gaz/gProdDrug.m4

./txt2m4.py gaz/gProdFoodDrink.txt | tr -s ' \n' ' ' | sed 's/. Lst.AlphaUp.*//g' > gaz/gProdFoodDrinkMisc.m4
./txt2m4.py gaz/gProdFoodDrink.txt | tr -s ' \n' ' ' | egrep -o 'Lst.AlphaUp.*' > gaz/gProdFoodDrinkFin.m4 

./txt2m4.py gaz/gProdCultivar.txt > gaz/gProdCultivar.m4

./txt2m4string.py gaz/gProdDevice.txt > gaz/gProdDevice.m4
./txt2m4string.py gaz/gProdOS.txt > gaz/gProdOS.m4
./txt2m4string.py gaz/gProdAppStore.txt > gaz/gProdAppStore.m4
./txt2m4string.py gaz/gProdSearchEngine.txt > gaz/gProdSearchEngine.m4
./txt2m4string.py gaz/gProdBrowser.txt > gaz/gProdBrowser.m4
./txt2m4string.py gaz/gProdTechMisc.txt > gaz/gProdTechMisc.m4

# EnamexEvt___
./txt2m4.py gaz/gEventMisc.txt gaz/gEventFin.txt gaz/gEventWarFin.txt | tr -s ' \n' ' ' | sed 's/. Lst.AlphaUp.*//g' > gaz/gEventMisc.m4
./txt2m4.py gaz/gEventMisc.txt gaz/gEventFin.txt gaz/gEventWarFin.txt | tr -s ' \n' ' ' | egrep -o 'Lst.AlphaUp.*' > gaz/gEventFin.m4
