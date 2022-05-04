# Dynamic Voice Channels

## Introduction

Have you always wanted a fast discord bot that automatically creates new voice channels and is also easy to use?  Then this bot is perfect for you. It automatically creates a new voice channel as soon as you join a certain channel and deletes it afterwards.

## Examples

- **Dynamic channels:**

![Example](https://i.imgur.com/40zpISm.gif)

## Installation

**Python 3.8 or higher is required**

1. Use pip to restore required packages:
```
pip install -r requirements.txt
```

2. Set an environment variable named `BOT_TOKEN`:
```
export BOT_TOKEN="your discord bot token here"
```

3. Open a command line in your bot's directory and start it with python:
```
python ./start-bot.py
```

## Docker

You can also run this bot from a Docker container using the included Dockerfile. You just need to set the `BOT_TOKEN` environment variable, and Docker will take care of the rest:

```
docker build -t MyDiscordBot:latest .
docker run -it -e "BOT_TOKEN=$YOUR_DISCORD_BOT_TOKEN" MyDiscordBot:latest
```

## Wiki

[wiki](https://github.com/Pawl-Patrol/Dynamic-Voice-Channels/wiki)
