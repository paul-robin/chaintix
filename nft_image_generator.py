import sys
import os
import qrcode
from PIL import Image, ImageDraw, ImageFont

args = sys.argv[1:]
collection_name = args[0]
collection_tier = args[1]
transactionURL = "https://polygonscan.com/tx/"+args[2]

qrCodeImg = qrcode.make(transactionURL).resize((328,328))
nftTemplate = Image.open("nft_template.png")
nftTemplate.paste(qrCodeImg, (92, 84))

textFont = ImageFont.truetype("BebasNeue-Regular.ttf", 30)
image_editable = ImageDraw.Draw(nftTemplate)
image_editable.text((20, 432), "Event: "+collection_name, (255, 255, 255), font=textFont)
image_editable.text((20, 462), "Ticket tier: "+collection_tier, (255, 255, 255), font=textFont)

nftTemplate.save(os.getcwd()+"\\collections\\"+collection_name+"\\images\\nft_ticket.png")