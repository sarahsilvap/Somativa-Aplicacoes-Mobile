import os
from pathlib import Path
from datetime import timedelta

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = os.getenv('DJANGO_SECRET_KEY', 'chave-secreta-em-desenv')  # Defina a chave secreta em uma variável de ambiente para produção

DEBUG = True  # Em produção, defina como False

ALLOWED_HOSTS = ['*']  # Em produção, substitua por domínios específicos como ['www.seusite.com']

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # libs
    'rest_framework',
    'corsheaders',  # Lib de CORS

    # apps
    'api',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # deve vir antes de CommonMiddleware
    'django.middleware.common.CommonMiddleware',  # Remover duplicação
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
]

ROOT_URLCONF = 'backend_delivery.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'backend_delivery.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',  # Mude para PostgreSQL em produção
        'NAME': BASE_DIR / 'db.sqlite3',         # Em produção, configure um banco de dados mais robusto
    }
}

AUTH_PASSWORD_VALIDATORS = [
    # Adicione validadores de senha conforme necessário
]

LANGUAGE_CODE = 'pt-br'
TIME_ZONE = 'America/Sao_Paulo'
USE_I18N = True
USE_TZ = True
STATIC_URL = '/static/'

# CORS - permitir acesso do app
CORS_ALLOW_ALL_ORIGINS = True  # Permite acesso de qualquer domínio (ideal para desenvolvimento)

# Em produção, use CORS_ALLOWED_ORIGINS para restringir
# CORS_ALLOWED_ORIGINS = [
#     "http://localhost:51705",  # URL do seu front-end local
#     "https://seusite.com",     # Domínio de produção
# ]

# DRF + JWT
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',  # Exige autenticação
    ),
}

# Simple JWT settings
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(days=1),
    'AUTH_HEADER_TYPES': ('Bearer',),
    # Adicione mais opções se necessário, como o refresh token
    # 'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
}

# Defina variáveis de ambiente para segredos
# SECRET_KEY = os.getenv('DJANGO_SECRET_KEY', 'chave-secreta-em-desenv')  # Substitua por uma chave segura em produção

# Defina seu banco de dados em produção
# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.postgresql',
#         'NAME': 'nome_do_banco',
#         'USER': 'usuario',
#         'PASSWORD': 'senha',
#         'HOST': 'localhost',
#         'PORT': '5432',
#     }
# }
