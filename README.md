# Dissertation Logger

This is the public facing version of the chat logger I used for my dissertation. I am presently building a more custom version of this with the new API for future use, but this is ultimately a stripped down version of the logger by [Bernardo Pire](https://github.com/bernardopires/twitch-chat-logger "twitch-chat-logger"). Unlike the original, this logger was altered to be more category-specific (e.g., Hearthstone or Just Chatting).

The bots are defaulted to having 2 bots log 50 channels. The Twitch API limits you to 100 responses, which would be logged by 4 bots (i.e., 25 bots per channel). You can alter this distribution in ``manager.py`` or the default number of channels in ``main.py``.

I ran these bots on a small cluster of Raspberry Pis running Rasbian. This code has worked on all versions of Linux I have tested it on, including Ubuntu on Windows.

You **must** have a Twitch account to use this logger.

**NOTE:** I am not a programmer. This is strictly public so that it's accessible to those with whom I discuss my dissertation.

## Instructions
Install this repository using git.

    git clone https://github.com/apleith/dissertation_logger.git

Rename ``settings.py.example`` to ``settings.py``

Update the ``IRC`` dictionary in ``settings.py`` with your Twitch account credentials. If you do not have one, you can get your oauth password from [here](http://twitchapps.com/tmi/ "Twitch Chat OAuth Password Generator").

    IRC = {
        'SERVER': 'irc.twitch.tv',
        'NICK': 'USERNAME',
        'PASSWORD': 'oauth:YOUR_KEY_HERE',
        'PORT': 6667,
    }

Update the ``API`` dictionary in ``settings.py`` with your ``Client-Id``. If you do not have one, you must first register a new application with Twitch by signing into the [Twitch Developers](https://dev.twitch.tv/ "Twitch Developers") site, click VIEW APPS, and then click Register Your Application.

    API = {
        'CLIENTID': 'YOUR_CLIENT_ID'
    }

Install [PostgreSQL](https://www.postgresql.org/download/ "PostgreSQL Download"), choose a username and password, and create a database.

Update the ``DATABASE`` dictionary inside ``settings.py`` with your credentials.

    DATABASE = {
        'NAME': 'YOUR_DATABASE',
        'USER': 'YOUR_USERNAME',
        'PASSWORD': 'YOUR_PASSWORD',
        'HOST': 'localhost',
    }

Create the default tables by running ``create_tables.sql``.

    psql YOUR_DATABASE -f create_tables.sql -U YOUR_USERNAME -h localhost -W

Install the Python library dependencies with pip.

    pip install -r requirements.txt

If you are not interested in category specific logging, you now just need to run ``main.py`` with default settings (2 bots logging 50 channels).

    python main.py

You can log a different number of channels by using ``n`` (max = 100) and specific channels using ``c``. If you want to save the output, you can use ``f``.

    python main.py -n 25 -f output.txt
    python main.py -c CHANNEL1 CHANNEL2 CHANNEL3

## Category Specific Logging
If you are interested in creating a category-specific logger, you'll have to use the provided ``CATEGORY`` folder with the necessary modifications.

Copy the ``CATEGORY`` folder and paste it titled with a spaceless version of chosen category (e.g., ``just_chatting``). This title will be the basis of category specific logging.

In ``create_tables.sql`` and ``db_logger.py``, find and replace all ``CATEGORY`` with the non-space version of the title you have selected for logging (e.g., just_chatting).

``create_tables.sql`` example

    CREATE TABLE CATEGORY_chat_log (
      id integer NOT NULL,
      channel character varying(64) NOT NULL,
      sender character varying(64) NOT NULL,
      message character varying(512) NOT NULL,
      date bigint NOT NULL
      );

``db_logger.py`` example

      def log_chat(self, sender, message, channel):
          if len(message) > 512:
              message = message[:512]

          if self.cursor.closed:
              return

          try:
              self.cursor.execute("INSERT INTO CATEGORY_chat_log (sender, message, channel, date) VALUES (%s, %s, %s, %s)",
                                  (sender, message, channel, current_time_in_milli()))
          except psycopg2.DataError as e:
              print e
              print message

In ``utils.py``, find and replace ``CATEGORY`` with Twitch's official title for the category (e.g., Just Chatting).

    def get_top_streams(n):
    twitch_api_url = "https://api.twitch.tv/kraken/streams/?limit=%i&language=en&game=%s" % (n, urllib.quote('CATEGORY'))
    headers = {'Client-Id': API['CLIENTID']}
    try:
       return json.loads(requests.get(twitch_api_url, headers=headers).text)['streams']
    except (ValueError, ConnectionError, SSLError):
        time.sleep(5)
        return get_top_streams(n)

Once all instances of ``CATEGORY`` have been replaced, you should now create the category-specific table.

    psql YOUR_DATABASE -f CATEGORY/create_tables.sql -U YOUR_USERNAME -h localhost -W

All the is left is deploying the category-specific bots.

    python CATEGORY/main.py
