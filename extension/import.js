
const endpoint = 'http://localhost:3000'
const token = 'xLaHyU-JaIz3rlfSIlGvDBVx234bT35IiXG7HHT_UVg'
const instance = axios.create({
    baseURL: endpoint + '/api',
    timeout: 50000,
    headers: {'Authorization': 'Bearer '+token}
});


// "name": "God's theme",
//             "artist_name": "Neal Morse",
//             "album_name": "Testimony",
//             "cover": "https://lastfm.freetls.fastly.net/i/u/300x300/f00e07d4c2e842a49f914e591abebd30.webp"

async function importData(type, rows) {
    var payload = {}
    payload[type] = rows
    const { data } = await instance.post(`/v1/music/collections`, payload);
    console.log(data)
}


async function importFromJson(type, rows) {
    var dateTypeMap = {
        song: 'songs',
        album: 'albums',
        artist: 'artists'
    }

    var dateType = dateTypeMap[type]

    var parsedSongs = rows.map(_ => {
        if(type == 'song') {
            return {
                name: _.song_name,
                artist_name: _.artist_name,
                album_name: _.album_name,
                cover: _.album_logo
            }
        }

        if(type == 'album') {
            return {
                name: _.album_name,
                artist_name: _.artist_name,
                cover: _.album_logo
            }
        }

        if(type == 'artist') {
            return {
                name: _.artist_name,
                cover: _.artist_logo,
                country: _.area
            }
        }
    });

    const stepItems = chunk(parsedSongs, 300);
    for (let index = 0; index < stepItems.length; index++) {
        try {
            const tasks = stepItems[index];
            const results = await importData(dateType, tasks)
        } catch (e) {
            console.log("chunkPromise", e);
        }
    }
    console.log('all done')
}


async function importAll() {
    for(var type in app.userData) {
        const rows = app.userData[type]
        await importFromJson(type, rows)
    }
}