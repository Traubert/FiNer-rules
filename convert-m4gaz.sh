#!/bin/sh

# Convert lists of e.g. multi-word names into m4 files that can be used as gazetteers

# EnamexOrg___
python3 txt2m4.py \
	gOrgCorpMWordMisc.txt \
	gOrgRestaurant.txt \
	gOrgCorpStore.txt \
	gOrgAirline.txt \
	gOrgFashion.txt > gOrgCorpAll.m4

python3 txt2m4.py gOrgMiscFin.txt > gOrgMiscAll.m4

python3 txt2m4.py \
	gCultInstitution.txt \
	gCultPerformingGroupFin.txt \
	gCultPerformingGroup.txt > gOrgCult.m4

python3 txt2m4.py gCultPerformingGroupCongr.txt > gOrgCultCongr.m4

python3 txt2m4.py gMediaMWord.txt gMediaMWordFin.txt > gOrgMedia.m4   

python3 txt2m4.py gMediaMWordCongr.txt > gOrgMediaCongr.m4

python3 txt2m4.py gOrgAthTeam.txt > gOrgAthTeam.m4

# EnamexPrs___
python3 txt2m4.py \
	gPersMWordMisc.txt \
	gPersMWordFin.txt > gPersMWord.m4
python3 txt2m4.py \
	gMythicalBeingFin.txt \
	gMythicalBeing.txt > gPersFictional.m4

# EnamexLoc___
python3 txt2m4.py gLocPolMWordMisc.txt gLocPolMWordFin.txt > gLocPolMWord.m4
python3 txt2m4.py gLocPlace.txt gLocPlaceFin.txt > gLocPlace.m4
python3 txt2m4.py gLocGeoMWordFin.txt > gLocGeoMWord.m4
python3 txt2m4.py \
	gLocFictional.txt \
	gLocMythical.txt > gLocFictional.m4

# EnamexPro___
python3 txt2m4.py gProdMusic.txt gArtifact.txt > gProdMWord.m4
python3 txt2m4.py gProdGame.txt > gProdGame.m4
python3 txt2m4.py gProdVehicleBrand.txt > gProdVehicleBrand.m4
python3 txt2m4string.py gProdVehicleBrand.txt > gProdVehicleBrandStr.m4
python3 txt2m4.py gProdFilmTvMWord.txt gProdFilmTvMWordFin.txt > gProdFilmTvMWord.m4
python3 txt2m4.py gProdLitFin.txt > gProdLitMWord.m4
python3 txt2m4.py gProdDrug.txt > gProdDrug.m4
python3 txt2m4.py gProdFoodDrink.txt > gProdFoodDrink.m4
python3 txt2m4.py gProdCultivar.txt > gProdCultivar.m4

python3 txt2m4string.py hProdDevice.txt > hProdDevice.m4
python3 txt2m4string.py hProdOS.txt > hProdOS.m4
python3 txt2m4string.py hProdAppStore.txt > hProdAppStore.m4
python3 txt2m4string.py hProdSearchEngine.txt > hProdSearchEngine.m4
python3 txt2m4string.py hProdBrowser.txt > hProdBrowser.m4
python3 txt2m4string.py hProdTechMisc.txt > hProdTechMisc.m4

# EnamexEvt___
python3 txt2m4.py gEventMisc.txt gEventFin.txt gEventWarFin.txt > gEventMisc.m4
