# Examples of Pandoc

Requirements:
- [pandoc](https://pandoc.org/) 2.9 or higher

## Backlog

Docs:
- [テキスト整形のルール (Backlog記法) – Backlog ヘルプセンター](https://support-ja.backlog.com/hc/ja/articles/360035641594)
- [テキスト整形のルール (Markdown 記法) – Backlog ヘルプセンター](https://support-ja.backlog.com/hc/ja/articles/360036145833)

### Examples

Markdown to backlog wiki
```shell
cat markdown/example.md \
| pandoc -f gfm -t backlog/backlog.lua > example.backlog
```

## Redmine

Docs:
- [wikiの記法は？ — Redmine.JP](https://redmine.jp/faq/wiki/wiki_syntax/)

### Examples

Redmine wiki(textile) to Markdown
```shell
pandoc -f textile -s redmine/example.textile -t gfm -o example.md
```

Markdown to Redmine wiki(textile)
```shell
pandoc -f gfm -s markdown/example.md -t textile -o example.textile
```
