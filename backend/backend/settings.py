"""
Campus Connect - Django Settings
Add these configurations to your config/settings.py

This sets up:
- JWT authentication for Flutter
- CORS to allow Flutter to make requests
- File upload handling
- REST framework configuration
"""

from datetime import timedelta
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

# IMPORTANT: Change this in production!
SECRET_KEY = 'django-insecure-your-secret-key-change-in-production'

DEBUG = True

ALLOWED_HOSTS = ['*']  # Change in production to your domain


# ============================================================================
# INSTALLED APPS
# ============================================================================
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    # Third party apps for REST API and JWT
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',  # For logout functionality
    'corsheaders',  # Allows Flutter to make requests from different origin
    'django_filters',  # For advanced search/filtering (Sprint 4)
    
    # Your app
    'api',  # Your single app folder
]


# ============================================================================
# MIDDLEWARE - CORS must be at top!
# ============================================================================
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # Must be at the top!
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]


# ============================================================================
# CUSTOM USER MODEL
# ============================================================================
# Tell Django to use your custom User model from api/models.py
AUTH_USER_MODEL = 'api.User'


# ============================================================================
# REST FRAMEWORK CONFIGURATION
# ============================================================================
REST_FRAMEWORK = {
    # Use JWT for authentication
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    
    # Default permission: must be authenticated
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    
    # Pagination for large lists
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    
    # JSON rendering
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
    ],
    
    # Date/time format
    'DATETIME_FORMAT': '%Y-%m-%d %H:%M:%S',
}


# ============================================================================
# JWT CONFIGURATION
# ============================================================================
# How Flutter gets and uses JWT tokens:
# 1. Flutter sends username/password to /api/auth/login/
# 2. Django returns access token (15 min) and refresh token (7 days)
# 3. Flutter stores tokens locally
# 4. Flutter adds "Authorization: Bearer <access_token>" to all requests
# 5. When access token expires, Flutter uses refresh token to get new one

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(days=30),  # Token valid for 1 hour
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),     # Refresh valid for 7 days
    'ROTATE_REFRESH_TOKENS': True,                   # Get new refresh when using it
    'BLACKLIST_AFTER_ROTATION': True,                # Invalidate old refresh tokens
    
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': SECRET_KEY,
    
    'AUTH_HEADER_TYPES': ('Bearer',),  # Flutter sends: "Authorization: Bearer <token>"
    'AUTH_HEADER_NAME': 'HTTP_AUTHORIZATION',
    
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
    
    'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
    'TOKEN_TYPE_CLAIM': 'token_type',
}


# ============================================================================
# CORS CONFIGURATION (Allow Flutter to make requests)
# ============================================================================
# In development, allow all origins
# In production, specify your Flutter app's domain

CORS_ALLOW_ALL_ORIGINS = True  # For development only!

# For production, use this instead:
# CORS_ALLOWED_ORIGINS = [
#     'http://localhost:3000',
#     'http://your-flutter-web-domain.com',
# ]

CORS_ALLOW_CREDENTIALS = True

CORS_ALLOW_METHODS = [
    'DELETE',
    'GET',
    'OPTIONS',
    'PATCH',
    'POST',
    'PUT',
]

CORS_ALLOW_HEADERS = [
    'accept',
    'accept-encoding',
    'authorization',
    'content-type',
    'dnt',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
]


# ============================================================================
# DATABASE CONFIGURATION
# ============================================================================
# Using PostgreSQL (recommended for production)
# For development, you can use SQLite

# SQLite (development only)
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# PostgreSQL (recommended)
# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.postgresql',
#         'NAME': 'campus_connect',
#         'USER': 'your_db_user',
#         'PASSWORD': 'your_db_password',
#         'HOST': 'localhost',
#         'PORT': '5432',
#     }
# }

# MySQL
# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.mysql',
#         'NAME': 'campus_connect',
#         'USER': 'your_db_user',
#         'PASSWORD': 'your_db_password',
#         'HOST': 'localhost',
#         'PORT': '3306',
#     }
# }


# ============================================================================
# MEDIA FILES (User uploads: images, PDFs, etc.)
# ============================================================================
# Flutter uploads files to Django, Django saves them here
# Flutter can then access them via URLs like:
# http://localhost:8000/media/profiles/student_photo.jpg

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'


# ============================================================================
# STATIC FILES (CSS, JS, Admin panel)
# ============================================================================
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'


# ============================================================================
# URL CONFIGURATION
# ============================================================================
ROOT_URLCONF = 'backend.urls'


# ============================================================================
# TEMPLATES
# ============================================================================
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


# ============================================================================
# PASSWORD VALIDATION
# ============================================================================
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
        'OPTIONS': {
            'min_length': 8,
        }
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# ============================================================================
# INTERNATIONALIZATION
# ============================================================================
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'Africa/Algiers'  # Constantine, Algeria timezone
USE_I18N = True
USE_TZ = True


# ============================================================================
# DEFAULT PRIMARY KEY FIELD
# ============================================================================
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'


# ============================================================================
# LOGGING (Optional but helpful for debugging)
# ============================================================================
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
    },
}