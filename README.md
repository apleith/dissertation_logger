# dissertation_logger

A Twitch chat and stream-metadata logger, archived as it ran in December 2018 and January 2019 to collect the corpus behind:

Leith, A. P. (2021). Parasocial cues: The ubiquity of parasocial relationships on Twitch. *Communication Monographs, 88*(1), 111–129. https://doi.org/10.1080/03637751.2020.1868544

This release (v1.0) is the citable record of that instrument. It is not maintained software. It targets the Twitch API v5 ("Kraken"), which Twitch decommissioned on February 28, 2022, and it does not run against the current Twitch API. A Python 3 port on Helix and EventSub is planned as version 2.

## Credit

This code is a modification of **twitch-chat-logger** by **Bernardo Pires** (https://github.com/bernardopires/twitch-chat-logger, MIT License, 2015). Pires wrote the architecture and nearly all of the code: the threaded IRC bot, the manager that scales bots to channels, the PostgreSQL logger, and the stream-polling loop. The modifications here are small: a per-category stream filter, the English-language and partner filters, changed timing constants, and category-specific table names. Pires's permission notice is retained in `LICENSE`, and his work is listed in `CITATION.cff`. The `requirements.txt` also depends on his fork of the `irc` library.

## What is in this repository

| Path | What it is |
|---|---|
| `bot.py`, `manager.py`, `db_logger.py`, `main.py`, `utils.py`, `create_tables.sql` | The generic logger: top English-language streams on Twitch, any category. |
| `CATEGORY/` | A template for a category-specific logger (replace `CATEGORY` with a category name). |
| `archive/category-bot/` | The per-category bot that actually ran for the dissertation, with the `partner=true` filter and the list of 30 categories in `categories.txt`. Copied unchanged from the private build repository. |
| `CITATION.cff` | Citation metadata for this software, the 2021 article, and the original work. |

## How the instrument worked

Each category had its own bot. Every two minutes (median 120.8 seconds) the bot asked the Twitch API for the top 50 live, English-language, partnered streams in that category and logged each stream's channel, title, game, and viewer count to `stream_log`. It kept one IRC connection per 25 channels and joined a channel's chat only while that channel was on the current top-50 list, logging every message's channel, sender, text, and UTC timestamp to a per-category chat table. Nothing but text and stream metadata was ever stored: no images, audio, or video.

## The corpus it produced

- Collection window for the dissertation: December 17, 2018 to January 17, 2019.
- Categories: 25 games and 5 non-game categories were targeted (see `archive/category-bot/categories.txt`). The stream log holds 37 category names with at least 1,000 polling cycles; the extra names are category titles Twitch changed during or after the run.
- Stream log: 33,130,708 rows (channel, title, game, viewers, time).
- Chat: 44.4 million messages in the 2018 to 2019 wave that the 2021 article analyzed. A second run of the same bots in 2020 added 321.3 million messages, for 365,746,388 in the consolidated corpus.
- Channels: 117,943 distinct channels appeared in the raw logs before the partner, language, and message-count filters described in the article.

The corpus is held by the author. Chat text is not redistributed; per the Twitch Developer Services Agreement and the AoIR Internet Research: Ethical Guidelines 3.0, requests for derived data are handled case by case, with identifiers and code shared in preference to message text.

## Known defects in the archived code

These are preserved as they were, since the release documents what ran:

- `CATEGORY/utils.py` calls `urllib.quote` without importing `urllib`.
- `CATEGORY/create_table.sql` spells the table `CATEGRORY_chat_log` in its primary-key statement.
- The root `db_logger.py` does not write `stream_log`; the `CATEGORY/` and `archive/category-bot/` versions do.
- The code is Python 2 (`print` statements, `Queue`), and `requirements.txt` installs the IRC library over the `git://` protocol, which GitHub disabled in 2022.

## Why it no longer runs

| Component | Then | Now |
|---|---|---|
| Stream discovery | `GET https://api.twitch.tv/kraken/streams` with a Client-Id header | Decommissioned February 28, 2022. Replacement: `GET https://api.twitch.tv/helix/streams` with an OAuth token, `game_id`, and `language`. |
| Chat token | twitchapps.com/tmi password generator | Discontinued. A registered application and an OAuth user token with `chat:read` are required. |
| Chat transport | Plaintext IRC on port 6667, 25 channels per connection, unlimited connections | IRC still exists but Twitch recommends EventSub; one account may be in at most 100 chat rooms at once (since May 15, 2024). |
| Install | Python 2, `git://` dependency | Python 2 reached end of life January 1, 2020; `git://` was disabled March 15, 2022. |

## Original setup (2019), kept for the record

1. Rename `settings.py.example` to `settings.py` and fill the `IRC` dictionary with a Twitch account and OAuth password, the `API` dictionary with a Client-Id, and the `DATABASE` dictionary with PostgreSQL credentials.
2. Create the tables: `psql YOUR_DATABASE -f create_tables.sql -U YOUR_USERNAME -h localhost -W`
3. Install dependencies: `pip install -r requirements.txt`
4. Run: `python main.py` (defaults to 25 streams), `python main.py -n 50 -f output.txt`, or `python main.py -c CHANNEL1 CHANNEL2`.
5. For a category, copy `CATEGORY/`, replace every `CATEGORY` with the category's name in `create_table.sql`, `db_logger.py`, and `utils.py`, create its table, and run `python CATEGORY/main.py`.

## Citing

Cite the article above for the study and this release for the instrument. `CITATION.cff` carries both, plus the original work by Pires. The archived release is assigned a DOI through Zenodo; see the repository's release page.

## License

MIT. Copyright (c) 2015 Bernardo Pires for the original work; copyright (c) 2019 to 2026 Alex P. Leith for the modifications. See `LICENSE`.
