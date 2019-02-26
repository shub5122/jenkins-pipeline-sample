FROM python:latest
EXPOSE 8000
RUN pip install --upgrade pip && \
    pip install djangocms-installer && \
    mkdir /django-web
WORKDIR /django-web
RUN djangocms -f -p . talos
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
