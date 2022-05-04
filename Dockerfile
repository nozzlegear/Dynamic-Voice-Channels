FROM python:3-alpine
WORKDIR /app

# Install dependencies
RUN apk update && apk add python3-dev gcc libffi-dev libc-dev

# Restore packages using pip
COPY ./requirements.txt .
RUN pip3 install -r ./requirements.txt

# Copy source files
COPY . .

# Start the bot
CMD ["python3", "./start-bot.py"]
