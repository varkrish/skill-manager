FROM registry.access.redhat.com/ubi9/python-311:latest

USER root
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -q -r requirements.txt

COPY main.py        main.py
COPY marketplace.py marketplace.py
COPY ui/            ui/

EXPOSE 8091

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8091"]
