import json

resultat = []

with open("dialogueur.txt","r") as f:    
    lignes = f.readlines()
    for ligne in lignes:
        dico = {}
        personnage,emotion,texte = ligne.split("|")
        dico["character"] = personnage
        dico["emotion"] = emotion
        dico["text"] = texte.replace("\n","")
        dico["properties"] = []
        resultat.append(dico)


with open("resultat.txt","w") as f:
    json.dump(resultat,f)
