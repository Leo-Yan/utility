window.Krux||((Krux=function(){Krux.q.push(arguments);}).q=[]);
(function() {
  var clients = {
    'o_3013110282': '79816aa8-435a-471a-be83-4b3e0946daf2',
    'o_329591024': 'ed75826a-927e-4763-b4c7-e803a02e0cb6',
    'atl': '2f0b1245-61c7-4b29-9468-1d7686aa6dab',
    'bloom': '0ccccb05-8c21-4099-9838-fed4ceb7a239',
    'busin': '08ea07b8-908f-4d41-b3b3-2af0d93a5984',
    'cag': '53f13a23-c936-4f28-a6e1-8c94be836e4e',
    'cars': 'f1c061b9-c7fc-4dd4-8a51-39acb1f4a41e',
    'carmax': '6b8da686-2384-44b3-bbf9-99e2e44c6724',
    'centro': '7b3785dc-e5e8-4465-88e8-0bb2db048533',
    'esi': '8dc3c31a-331c-4c9b-a044-a82b2e82e330',
    'forb': '7c727c7f-01f2-46b1-bafa-55662a7e6db8',
    'gawk': 'f957ee1a-d222-492b-b86e-4b6eba139638',
    'gam' : 'bfb3d1d9-6a65-4dad-90d0-d5d134b9c7af',
    'kel': '696bde53-e9e2-4205-84af-cde254e436fb',
    'kgo': 'a5fbc948-51af-49e7-89ff-5e82fdd54e94',
    'man': 'f2aaa14d-71b0-4cbc-a074-0d62423d7764',
    'mere': '1b008fc9-b074-4b2e-8e4a-c1e1f07d344b',
    'mlz': '66b7958c-e7be-4c99-8484-175973202867',
    'nbc': '54983c83-8810-4a6b-9ff1-81f7349ce967',
    'nyp': '004480f6-3846-481a-abb4-46a3293402ae',
    'nyt': '79816aa8-435a-471a-be83-4b3e0946daf2',
    'pandora': '992b4e94-c474-4717-82db-512456587844',
    'pga': '5e601765-9a1c-4f9c-a7dd-492f3d5dbd9c',
    'salp': '88a388a7-f531-4ebc-929a-e93320909d66',
    'trib': 'ed0a1b17-4fcc-461f-801f-5b1a729fa84d',
    'dmedia': '66822801-aa35-4f0d-a6ab-78970028f03f',
    'fut': '31c1ae6b-6f4f-45a3-9bad-d4aad9c3af60',
    'tur': 'e9eaedd3-c1da-4334-82f0-d7e3ff883c87',
    'uber': 'ba90b137-76aa-42ec-8c15-08f1a7670ed9',
    'vail': '5fe4c117-d66b-4264-89e1-feae9c18213e',
    'vice': 'e959415e-6d78-4761-bd97-5f3693023670',
    'vox': '36b99e73-5c79-40db-9954-69f256f24981',
    'wapo': '415dda7b-13ba-40f3-9a60-eb3ba310f160',
    'wenn': '2e379285-4c71-4e15-bc41-4d8cfe3ec56c',
    'jetblue': '5d3a6c7b-c015-447c-a038-7762f3c3b014'
  };

  var partners = {
    '5b0a9e4a-b3f4-4c19-a633-10fce940f97b': ['pandora', 'cag', 'carmax', 'vail', 'jetblue'],
    '786e1ff0-cc85-42cf-954e-8e0142346699': ['cag', 'mlz'],
    'a272cefb-df39-4fcd-beff-79cd6cdf22ec': ['atl', 'bloom', 'busin', 'cars', 'centro', 'dmedia', 'esi', 'forb', 'fut',
        'gam', 'gawk', 'kel', 'kgo', 'man', 'mere', 'nbc', 'nyp', 'nyt', 'pga', 'salp', 'trib', 'tur', 'uber', 'vice', 'vox',
        'wapo', 'wenn'],
    '473c2793-2f85-4958-8979-aeb84b5406ed': ['o_3013110282', 'o_329591024']
  };

  var now = function() {
    return new Date().getTime();
  };

  var get_item = function(key) {
    try {
      var entry = JSON.parse(localStorage.getItem(key)||"0");
      if (!entry) {
        return null;
      }
      if (entry.ttl && entry.ttl + entry.now < now()) {
        localStorage.removeItem(key);
        return null;
      }
      return entry.value;
    } catch (e) {
      return null;
    }
  };

  var set_item = function(key, value, ttl ) {
    try {
      localStorage.setItem( key, JSON.stringify({
        ttl   : ttl || 0,
        now   : now(),
        value : value
      }) );
    } catch (e) { /* Ignore security error on Safari */ }
  };

  var get_query_parameters = function(params) {
    if (!params) {
      return {};
    }
    var ret = {};
    for (var i = 0; i < params.length;++i) {
      var param=params[i].split('=', 2);
      if (param.length == 1) {
        ret[param[0]] = "";
      } else {
        ret[param[0]] = decodeURIComponent(param[1].replace(/\+/g, " "));
      }
    }
    return ret;
  };

  var lookup_client = function() {
    var partner = '';
    var client = '';
    var nodes = document.getElementsByTagName('script');
    var limit = nodes.length;
    while (limit--) {
      var src = nodes[limit].src;
      if (/^https?:\/\/cdn(-stage)?.krxd.net\/partnerjs\/segments_to_partner\.js/.test(src || '')) {
        params = get_query_parameters(src.split('?', 2)[1].split('&'));
        client = params["client"];
        partner = params["partner"];
        break;
      }
    }
    if (partner in partners) {
      var partner_clients = partners[partner];
      if (partner_clients.indexOf(client) > 0) {
        return client;
      }
    }
    return '';
  };

  kx_partner_segments = function(segment_json) {
    var k = client + '_segments';
    if (segment_json && segment_json.body && segment_json.body.segments) {
      v =  segment_json.body.segments;
    } else {
      v = [];
    }
    Krux[k] = v;
    set_item(k, v, 600000); // Wait for 10 min
  };

  var client = lookup_client();
  if (client) {
    var key = client + '_segments';
    var segs = get_item(key);
    if (segs) {
      Krux[key] = segs;
    } else {
      var client_id = clients[client];
      if (client_id) {
        var script = document.createElement('script');
        script.src = "https://cdn.krxd.net/userdata/get?pub="+client_id+"&callback=kx_partner_segments";
        var sibling = document.getElementsByTagName('script')[0];
        sibling.parentNode.insertBefore(script, sibling);
      }
    }
  }
})();
