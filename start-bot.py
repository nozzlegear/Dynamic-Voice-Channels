from bot import client
from os import environ

TOKEN = environ["BOT_TOKEN"]

if __name__ == '__main__':
    bot = client.Bot()
    bot.run(TOKEN)
