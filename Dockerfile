FROM python:3-alpine
WORKDIR /app

# Install dependencies for psutil
RUN apk update && apk add python3-dev gcc libffi-dev libc-dev

# Restore dependencies as noted in README.md
RUN pip3 install disnake
RUN pip3 install psutil

# Copy source files
COPY . .

# Start the bot
CMD ["python3", "./start-bot.py"]
