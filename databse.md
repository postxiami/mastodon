### track
- name
- album_id
- artist_id
- track_no

bin/rails generate model Track name:string body:text artist_id:integer album_id:integer track_no:integer

### album
- hash
- name
- cover
- desc
- year
- artist_id

bin/rails generate model Album name:string cover:string year:integer artist_id:integer tags:string desc:text

### artist
- name
- cover
- desc
- gener

bin/rails generate model Artist name:string cover:string desc:text

### music_tags
- name
- desc

### music_favoite
- type
- object_id
- account_id

bin/rails generate model MusicFavoite type:string account_id:integer object_id:integer

### album_tags
- album_id
- tag_id

### artist_tags
- artist_id
- tag_id
