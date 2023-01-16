import sys
import shutil
import os

args = sys.argv[1:]
collection_name = args[0]
collection_symbol = args[1]
collection_tiers = [arg.strip('[]').split(',') for arg in args[2:]]

tier_lines = ""
for i in range(len(collection_tiers)):
    tier_lines = tier_lines+'        tiers[{}] = Tier({{tierName: "{}", price: {} ether, maxPrice: {} ether, totalSupply: {}, maxSupply: {}, startingIndex: {}, mintsPerAddress: {}}});\n'.format(i, *collection_tiers[i])

trading_tiers = "        uint8 tokenTier;\n"
for i in range(len(collection_tiers)-1, -1, -1):
    if (i == len(collection_tiers)-1):
        trading_tiers = trading_tiers+'        if (tokenId >= {}){{tokenTier = {};}}\n'.format(collection_tiers[i][5], i)
    else:
        trading_tiers = trading_tiers+'        else if (tokenId >= {}){{tokenTier = {};}}\n'.format(collection_tiers[i][5], i)

print("name: "+collection_name+" ("+collection_symbol+")")
print("tiers:\n"+tier_lines)
print(trading_tiers)

file_string = ""
with open(os.getcwd()+"\\event_collection.sol", 'r') as f:
    for line in f.readlines():
        file_string = file_string+line

    file_string = file_string.replace("COLLECTION_NAME", collection_name)
    file_string = file_string.replace("COLLECTION_TIERS", tier_lines)
    file_string = file_string.replace("TRADING_TIERS", trading_tiers)

os.mkdir(os.getcwd()+"\\collections\\"+collection_name)
os.mkdir(os.getcwd()+"\\collections\\"+collection_name+"\\images")
os.mkdir(os.getcwd()+"\\collections\\"+collection_name+"\\json")
shutil.copyfile(os.getcwd()+"\\event_collection.sol", os.getcwd()+"\\collections\\"+collection_name+"\\"+collection_name+".sol")

with open(os.getcwd()+"\\collections\\"+collection_name+"\\"+collection_name+".sol", 'w') as f:
    f.writelines(file_string)