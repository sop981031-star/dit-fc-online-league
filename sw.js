/* V14.5: network-first HTML; never cache authenticated pages, requests, API responses, or Supabase traffic. */
const CACHE='dit-fc-v145-static-1';
const ASSETS=['./offline.html','./assets/dit-fc-192.png','./assets/dit-fc-512.png'];
self.addEventListener('install',event=>{event.waitUntil(caches.open(CACHE).then(cache=>cache.addAll(ASSETS)));self.skipWaiting()});
self.addEventListener('activate',event=>{event.waitUntil(caches.keys().then(names=>Promise.all(names.filter(name=>name.startsWith('dit-fc-')&&name!==CACHE).map(name=>caches.delete(name)))));self.clients.claim()});
self.addEventListener('fetch',event=>{
 if(event.request.mode!=='navigate'||event.request.method!=='GET')return;
 const url=new URL(event.request.url);if(url.origin!==self.location.origin)return;
 event.respondWith(fetch(event.request).catch(async()=> (await caches.match('./offline.html'))||new Response('연결을 확인해 주세요.',{status:503})));
});
