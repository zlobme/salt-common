{% set conf = salt['pillar.get']('carbon:graphite-web:local-settings', {}) %}
## Graphite local_settings.py
# Managed by Salt

#####################################
# Filesystem Paths #
#####################################
# Change only GRAPHITE_ROOT if your install is merely shifted from /opt/graphite
# to somewhere else
GRAPHITE_ROOT = '/usr/share/graphite-web'

# Most installs done outside of a separate tree such as /opt/graphite will only
# need to change these three settings. Note that the default settings for each
# of these is relative to GRAPHITE_ROOT
CONF_DIR = '/etc/graphite-web'
STORAGE_DIR = '/var/lib/carbon'
CONTENT_DIR = '/usr/share/graphite-web/webapp/content'

## Data directories
# NOTE: If any directory is unreadable in DATA_DIRS it will break metric browsing
WHISPER_DIR = '/var/lib/carbon/whisper'
CERES_DIR = '/var/lib/carbon/ceres'
RRD_DIR = '/var/lib/carbon/rrd'
DATA_DIRS = [WHISPER_DIR, CERES_DIR, RRD_DIR] # Default: set from the above variables
LOG_DIR = '/var/log/graphite-web/'
INDEX_FILE = '/var/lib/carbon/index'  # Search index file
FETCH_TIMEOUT = {{ conf.get('fetch-timeout', 30) }}
FIND_TIMEOUT = {{ conf.get('find-timeout', 30) }}

#####################################
# General Configuration #
#####################################
# Set this to a long, random unique string to use as a secret key for this
# install. This key is used for salting of hashes used in auth tokens,
# CRSF middleware, cookie storage, etc. This should be set identically among
# instances if used behind a load balancer.
SECRET_KEY = '{{ conf['secret-key'] }}'

## REMOTE_USER authentication. See: https://docs.djangoproject.com/en/dev/howto/auth-remote-user/
USE_REMOTE_USER_AUTHENTICATION = True

# In Django 1.5+ set this to the list of hosts your graphite instances is
# accessible as. See:
# https://docs.djangoproject.com/en/dev/ref/settings/#std:setting-ALLOWED_HOSTS
#ALLOWED_HOSTS = [ '*' ]

# Set your local timezone (Django's default is America/Chicago)
# If your graphs appear to be offset by a couple hours then this probably
# needs to be explicitly set to your local timezone.
TIME_ZONE = '{{ conf.get('time-zone', 'Europe/Moscow') }}'

# Logging
LOG_RENDERING_PERFORMANCE = {{'True' if conf.get('log-rendering-performance', False) else 'False'}}
LOG_CACHE_PERFORMANCE = {{'True' if conf.get('log-cache-performance', False) else 'False'}}
LOG_METRIC_ACCESS = {{'True' if conf.get('log-metric-access', False) else 'False'}}

# Enable full debug page display on exceptions (Internal Server Error pages)
DEBUG = {{'True' if conf.get('debug', False) else 'False'}}

# This lists the memcached servers that will be used by this webapp.
# If you have a cluster of webapps you should ensure all of them
# have the *exact* same value for this setting. That will maximize cache
# efficiency. Setting MEMCACHE_HOSTS to be empty will turn off use of
# memcached entirely.
#
# You should not use the loopback address (127.0.0.1) here if using clustering
# as every webapp in the cluster should use the exact same values to prevent
# unneeded cache misses. Set to [] to disable caching of images and fetched data
#MEMCACHE_HOSTS = ['10.10.10.10:11211', '10.10.10.11:11211', '10.10.10.12:11211']
#DEFAULT_CACHE_DURATION = 60 # Cache images and data for 1 minute

#####################################
# Email Configuration #
#####################################
# This is used for emailing rendered Graphs
# Default backend is SMTP
#EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
#EMAIL_HOST = 'localhost'
#EMAIL_PORT = 25
#EMAIL_HOST_USER = ''
#EMAIL_HOST_PASSWORD = ''
#EMAIL_USE_TLS = False
# To drop emails on the floor, enable the Dummy backend:
#EMAIL_BACKEND = 'django.core.mail.backends.dummy.EmailBackend'


##########################
# Database Configuration #
##########################
# By default sqlite is used. If you cluster multiple webapps you will need
# to setup an external database (such as MySQL) and configure all of the webapp
# instances to use the same database. Note that this database is only used to store
# Django models such as saved graphs, dashboards, user preferences, etc.
# Metric data is not stored here.
#
# DO NOT FORGET TO RUN 'manage.py syncdb' AFTER SETTING UP A NEW DATABASE
#
# The following built-in database engines are available:
#  django.db.backends.postgresql_psycopg2
#  django.db.backends.mysql
#  django.db.backends.sqlite3
#  django.db.backends.oracle
{% set db = conf['database'] %}
DATABASES = {
   'default': {
       'ENGINE': '{{ db['engine'] }}',
       'HOST': '{{ db['host'] }}',
       'PORT': '{{ db['port'] }}',
       'USER': '{{ db['user'] }}',
       'NAME': '{{ db['name'] }}',
       'PASSWORD': '{{ db['password'] }}'
   }
}



#########################
# Cluster Configuration #
#########################
# (To avoid excessive DNS lookups you want to stick to using IP addresses only in this entire section)
#
# This should list the IP address (and optionally port) of the webapp on each
# remote server in the cluster. These servers must each have local access to
# metric data. Note that the first server to return a match for a query will be
# used.
#CLUSTER_SERVERS = ["10.0.2.2:80", "10.0.2.3:80"]

## These are timeout values (in seconds) for requests to remote webapps
#REMOTE_STORE_FETCH_TIMEOUT = 6   # Timeout to fetch series data
#REMOTE_STORE_FIND_TIMEOUT = 2.5  # Timeout for metric find requests
#REMOTE_STORE_RETRY_DELAY = 60    # Time before retrying a failed remote webapp
#REMOTE_FIND_CACHE_DURATION = 300 # Time to cache remote metric find results

## Prefetch cache
# set to True to fetch all metrics using a single http request per remote server
# instead of one http request per target, per remote server.
# Especially useful when generating graphs with more than 4-5 targets or if
# there's significant latency between this server and the backends. (>20ms)
#REMOTE_PREFETCH_DATA = False


## Remote rendering settings
# Set to True to enable rendering of Graphs on a remote webapp
#REMOTE_RENDERING = True
# List of IP (and optionally port) of the webapp on each remote server that
# will be used for rendering. Note that each rendering host should have local
# access to metric data or should have CLUSTER_SERVERS configured
#RENDERING_HOSTS = []
#REMOTE_RENDER_CONNECT_TIMEOUT = 1.0

# If you are running multiple carbon-caches on this machine (typically behind a relay using
# consistent hashing), you'll need to list the ip address, cache query port, and instance name of each carbon-cache
# instance on the local machine (NOT every carbon-cache in the entire cluster). The default cache query port is 7002
# and a common scheme is to use 7102 for instance b, 7202 for instance c, etc.
#
# You *should* use 127.0.0.1 here in most cases
#CARBONLINK_HOSTS = ["127.0.0.1:7002:a", "127.0.0.1:7102:b", "127.0.0.1:7202:c"]
#CARBONLINK_TIMEOUT = 1.0
# Using 'query-bulk' queries for carbon
# It's more effective, but python-carbon 0.9.13 (or latest from 0.9.x branch) is required
# See https://github.com/graphite-project/carbon/pull/132 for details
#CARBONLINK_QUERY_BULK = False

#####################################
# Additional Django Settings #
#####################################
# Uncomment the following line for direct access to Django settings such as
# MIDDLEWARE_CLASSES or APPS
#from graphite.app_settings import *
