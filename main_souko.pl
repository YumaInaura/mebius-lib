
use strict;
use Mebius::BBS;
package Mebius;

#-----------------------------------------------------------
# 倉庫ページ
#-----------------------------------------------------------
sub Souko{

my($all_bbs) = Mebius::BBS::all_bbs_hash();

	foreach(keys %$all_bbs ){
		
	}


my $html = q(

<h1>倉庫</h1>
使われなくなったページを収納しています<br>

<h2>掲示板</h2>
<div class="word-spacing line-height-large">
<a href="http://mb2.jp/_moe/">萌え</a>
<a href="http://mb2.jp/_nhr/">なりハルヒ</a>
<a href="http://mb2.jp/_ovs/">ビジュアル</a>
<a href="http://mb2.jp/_nmn/">なりマナー</a>
<a href="http://mb2.jp/_ive/">イベント</a>
<a href="http://mb2.jp/_mra/">マナー</a>
<a href="http://mb2.jp/_str/">釣り</a>
<a href="http://mb2.jp/_kgm/">テキゲー</a>
<a href="http://mb2.jp/_csd/">サンデー</a>
<a href="http://mb2.jp/_sbs/">バスケ</a>
<a href="http://mb2.jp/_gff/">FF</a>
<a href="http://mb2.jp/_grp/">ＲＰＧ</a>
<a href="http://mb2.jp/_gai/">外国</a>
<a href="http://mb2.jp/_sbb/">野球</a>
<a href="/_acm/">4コマ</a>
<a href="/_uam/">運営</a>
<a href="http://mb2.jp/_dgs/">大学生</a>
<a href="/_aristotle/">他創作</a>
<a href="/_sen/">告知</a>
<a href="/_kns/">感想</a>
<a href="/_nws/">ニュース</a>
<a href="/_knk/">環境</a>
<a href="/wiki/poem/">創Wiki</a>
<a href="/kouryuujou/kouryuujou.cgi">詩投稿城３世</a>
<a href="/_skw/">詩会話城</a>
<a href="/_psi/">言葉遊び</a>
<a href="/_kjb/">自由掲示板</a>
<a href="/_bunngaku/">文学掲示板</a>
<a href="/_shk/">政治掲示板</a>
<a href="http://mb2.jp/_ini/">育児記</a>
<a href="http://mb2.jp/_shf/">主婦</a>
<a href="http://mb2.jp/_prg/">プログラム</a>
<a href="http://mb2.jp/_tnp/">単発</a>
<a href="http://mb2.jp/_ztg/">雑学</a>
<a href="http://mb2.jp/_ork/">ロック</a>
<a href="http://mb2.jp/_opp/">ポップス</a>
<a href="http://mb2.jp/_gac/">アクション</a>
<a href="http://mb2.jp/_gff/">ＦＦ</a>
<a href="http://mb2.jp/_gdo/">ドラクエ</a>
<a href="http://mb2.jp/_gmt/">メタルギア</a>
<a href="http://mb2.jp/_gme/">メガテン</a>
<a href="http://mb2.jp/_gbj/">牧場物語</a>
<a href="http://mb2.jp/_gpz/">パズル</a>
<a href="http://mb2.jp/_gst/">シューティング</a>
<a href="http://mb2.jp/_shm/">趣味</a>
<a href="http://mb2.jp/_ojp/">邦楽</a>
<a href="http://mb2.jp/_ocd/">ＤＶＤ</a>
<a href="http://mb2.jp/_cco/">ちゃお</a>
<a href="http://mb2.jp/_tks/">特撮</a>
<a href="http://mb2.jp/_sfg/">ゴルフ</a>
<a href="http://mb2.jp/_kdn/">家電</a>
<a href="http://mb2.jp/_mns/">マンション</a>
<a href="http://mb2.jp/_car/">自動車</a>
<a href="http://mb2.jp/_bwk/">バイク</a>
<a href="_oaq/">AquaTimez</a>
<a href="_knk/">観光</a>
<a href="_kag/">家具</a>
<a href="_psc/">パソコン</a>
<a href="_mbl/">携帯</a>
<a href="_iys/">癒し</a>
<a href="_cmg/">マガジン</a>
<a href="_bqz/">バカクイズ</a>
<a href="_buk/">文系</a>
<a href="_suk/">理数系</a>
<a href="_rks/">歴史</a>
<a href="http://mb2.jp/_gft/">格闘</a>
<a href="http://mb2.jp/_glk/">ロックマン</a>
<a href="http://mb2.jp/_den/">電車</a>
<a href="http://mb2.jp/_gne/">ネトゲ</a>
<a href="http://mb2.jp/_ofr/">洋楽</a>
</div>


);

Mebius::Template::gzip_and_print_all({ BCL => ["倉庫"] },$html);


}

1;
