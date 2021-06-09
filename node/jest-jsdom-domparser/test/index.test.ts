describe('test', () => {

  it('test', async () => {
    const rss = await fetch('https://www.soumu.go.jp/news.rdf').then(r => r.text())
    const dom = new DOMParser().parseFromString(rss, 'text/html');
    console.log(dom.getElementsByTagName('item').length);
  });

});
