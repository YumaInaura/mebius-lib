
use Time::Local;
package main;
use Mebius::Export;

#-----------------------------------------------------------
# メビウスリングの扉
#-----------------------------------------------------------

sub main_top{

# 宣言
my($mebigame_line,$menu_line);
my($my_account) = Mebius::my_account();
my($param) = Mebius::query_single_param();
our($device_type,$body_javascript,$kflag);

$main_mode = 1;

my $sub_title = "扉 - メビウスリング";
$head_link0_5 = "扉 &gt; ";

# 局所化
my($line);

# CSS定義
$css_text .= qq(
a.topimage{border-style:none;}
div.search_mode{text-indent:100px;font-size:80%;}
);

# 表示振り分け
if($device_type eq "mobile"){ &kget_items(); }

# BODY Javascript 定義
$body_javascript = qq( onload="document.google.q.focus()");

# 画像取得
my($line_image,$imgfile) = &main_top_select_image();

# Twitter取得
my($line_twitter) = &main_top_get_twitter();

# Google検索フォーム
if(!$kflag){
$google_form = qq(
<form method="get" action="http://www.google.co.jp/search" class="index_find" name="google">
<div>
<a href="http://www.google.co.jp/" rel="nofollow">
<img src="http://www.google.co.jp/logos/Logo_25wht.gif" class="google_img" alt="Google"></a>
<input type="text" name="q" size="41" maxlength="255" value="">
<input type="submit" name="btnG" value="Google 検索">
<div class="search_mode">
<label><input type="radio" name="sitesearch" value="mb2.jp" checked> メビウスリングから検索</label>
<label><input type="radio" name="sitesearch" value=""> Web全体から検索</label>
</div>
<input type="hidden" name="hl" value="ja">
<input type="hidden" name="domains" value="mb2.jp">
</div>
</form>
);
}

# メビゲー
$mebigame_line .= qq(<ul>);
$mebigame_line .= qq(<li><a href="http://aurasoul.mb2.jp/gap/ff/ff.cgi">メビリンアドベンチャー</a></li>);
#$mebigame_line .= qq(<li>ダンジョンワーク <a href="http://aurasoul.mb2.jp/_games/dungeon/">*</a></li>);
	if(!$kflag){
		$mebigame_line .= qq(<li><a href="http://aurasoul.mb2.jp/gap/dak/dak.cgi">メビタイピング</a> / <a href="http://aurasoul.mb2.jp/gap/dak2/dak.cgi">詩的なタイピング</a></li> );
	}
$mebigame_line .= qq(<li><a href="http://mb2.jp/_rousoku/">ロウソ\ク立て</a></li>);
$mebigame_line .= qq(</ul>);


# 開設日からの経過日数
my $site_start_time = 1097420400;
my $lefttimes = $time - $site_start_time;
my $leftdays = int( $lefttimes / (24*60*60) );
my($how_left_days) = utf8(Mebius::SplitTime("Get-till-day",time - $site_start_time));

# 誕生月、誕生日
my $start_birthday_year = 2004;
my $birthday_month = 10;
my $birthday_day = 11;

# 次の誕生年を求める
my $birthday_year;
if($main::thismonth >= $birthday_month && $main::today > $birthday_day){ $birthday_year = $main::thisyear + 1; }
else{ $birthday_year = $main::thisyear; }

#$main::thisyear+1
my($next_birthday_time) = &timelocal(00,00,00,$birthday_day,$birthday_month-1,$birthday_year);

my $next_birthday_lefttime = $next_birthday_time - $main::time;
my $next_birthday = int(($next_birthday_time - $main::time) / (24*60*60)) + 1;
#my ($next_birthday) = Mebius::SplitTime("Get-top-unit",$next_birthday_time - $main::time);

# 次が何周年目かを数える
my $next_round = $birthday_year - $start_birthday_year;

#my $next_birthday = 

#<li><a href="http://mb2.jp/">メビウスリング娯楽版</a> | <a href="http://mb2.jp/_main/past.html">過去ログ</a></li>

my $print .= qq(
<h1$main::kfontsize_h1>メビウスリングの扉</h1>
$google_form

<h2$main::kfontsize_h2>メニュー</h2>
<ul>
<li><a href="http://mb2.jp/">メビウスリング掲示板</a> | <a href="http://mb2.jp/_main/past.html">過去ログ</a></li>
<li><a href="${main::auth_url}">メビリンＳＮＳ</a> / <a href="http://aurasoul.mb2.jp/_one/">マイログ</a> / <a href="http://aurasoul.mb2.jp/etc/souko.html">倉庫</a></li>
<li><a href="http://mb2.jp/_main/newpaint-p-1.html">お絵かき</a></li>
<li><a href="http://aurasoul.mb2.jp/_early/">今日の早起きさん</a></li>
</ul>

<h2$main::kfontsize_h2>メビゲー</h2>
$mebigame_line
<h2$main::kfontsize_h2>時間</h2>
$start_birthday_year年$birthday_month月$birthday_day日 の開設から <strong class="red">$how_left_days ( $leftdays日 )</strong> が経過しました。

<br$main::xclose><br$main::xclose>$line_image
$line_twitter
);

#あと $next_birthday 日で $next_round周年です。

	if($my_account->{'master_flag'}){
		$print .= qq(<div>$param->{'q'}</div>);
	}

Mebius::Template::gzip_and_print_all({ source => "utf8" , Title => $sub_title },$print);

exit;

}

#-----------------------------------------------------------
# 画像選択
#-----------------------------------------------------------
sub main_top_select_image{

# 局所化
my($line,$i,$image,$imgurl,$tail,$nextflag);

# リターン
if($kflag){ return(); }


# 画像を定義
my @images = (


"http://aurasoul.mb2.jp/pct/10th/rel_6096.jpg",
"http://aurasoul.mb2.jp/pct/10th/rel_6106.jpg",
"http://aurasoul.mb2.jp/pct/10th/rel_6108.png",
"http://aurasoul.mb2.jp/pct/10th/rel_6109.png",
"http://aurasoul.mb2.jp/pct/10th/rel_6110.png",
"http://aurasoul.mb2.jp/pct/10th/rel_6111.png",
"http://aurasoul.mb2.jp/pct/10th/rel_6113.jpg",
"http://aurasoul.mb2.jp/pct/10th/rel_6114.jpg",
"http://aurasoul.mb2.jp/pct/10th/rel_6118.png",
"http://aurasoul.mb2.jp/pct/10th/rel_6119.jpg",
"http://aurasoul.mb2.jp/pct/10th/rel_6123.jpg",
"http://aurasoul.mb2.jp/pct/10th/rel_6126.jpg",

"http://aurasoul.mb2.jp/pct/7th/3.jpg",
"http://aurasoul.mb2.jp/pct/7th/4.jpg",
"http://aurasoul.mb2.jp/pct/7th/5.png",
"http://aurasoul.mb2.jp/pct/7th/7.jpg",
"http://aurasoul.mb2.jp/pct/7th/8.png",
"http://aurasoul.mb2.jp/pct/7th/9.png",
"http://aurasoul.mb2.jp/pct/7th/10.png",
"http://aurasoul.mb2.jp/pct/7th/11.png",
"http://aurasoul.mb2.jp/pct/7th/12.png",
"http://aurasoul.mb2.jp/pct/7th/13.png",
"http://aurasoul.mb2.jp/pct/7th/14.png",
"http://aurasoul.mb2.jp/pct/7th/15.png",
"http://aurasoul.mb2.jp/pct/7th/16.png",
"http://aurasoul.mb2.jp/pct/7th/17.jpg",
"http://aurasoul.mb2.jp/pct/7th/18.jpg",
"http://aurasoul.mb2.jp/pct/7th/20.png",
"http://aurasoul.mb2.jp/pct/7th/21.png",
"http://aurasoul.mb2.jp/pct/7th/22.jpg",
"http://aurasoul.mb2.jp/pct/7th/23.png",
"http://aurasoul.mb2.jp/pct/7th/25.png",
"http://aurasoul.mb2.jp/pct/7th/26.png",
"http://aurasoul.mb2.jp/pct/7th/27.png",
"http://aurasoul.mb2.jp/pct/7th/28.png",
"http://aurasoul.mb2.jp/pct/7th/29.png",


"http://aurasoul.mb2.jp/pct/7th/rel_2245.png",
"http://aurasoul.mb2.jp/pct/7th/rel_2250.png",
"http://aurasoul.mb2.jp/pct/7th/rel_2253.png",
"http://aurasoul.mb2.jp/pct/7th/rel_2279.png",
"http://aurasoul.mb2.jp/pct/7th/rel_2289.png",
"http://aurasoul.mb2.jp/pct/7th/rel_2291.jpg",
"http://aurasoul.mb2.jp/pct/7th/rel_2293.jpg",
"http://aurasoul.mb2.jp/pct/7th/rel_2294.jpg",
"http://aurasoul.mb2.jp/pct/7th/rel_2295.png",
"http://aurasoul.mb2.jp/pct/7th/rel_2296.png",
"http://aurasoul.mb2.jp/pct/7th/rel_2298.jpg",
"http://aurasoul.mb2.jp/pct/7th/rel_2299.png",
"http://aurasoul.mb2.jp/pct/7th/rel_2300.jpg",
"http://aurasoul.mb2.jp/pct/7th/rel_2301.jpg",
"http://aurasoul.mb2.jp/pct/7th/rel_2302.jpg",
"http://aurasoul.mb2.jp/pct/7th/rel_2305.jpg",
"http://aurasoul.mb2.jp/pct/7th/rel_2307.png",
"http://aurasoul.mb2.jp/pct/7th/rel_2312.jpg",
"http://aurasoul.mb2.jp/pct/7th/rel_2314.jpg",
"http://aurasoul.mb2.jp/pct/7th/rel_2324.jpg",
"http://aurasoul.mb2.jp/pct/7th/1318372891-31_s.jpg",

'http://aurasoul.mb2.jp/pct/6th/12.jpg',
'http://aurasoul.mb2.jp/pct/6th/13.png',
'http://aurasoul.mb2.jp/pct/6th/14.jpg',
'http://aurasoul.mb2.jp/pct/6th/15.png',
'http://aurasoul.mb2.jp/pct/6th/17.png',
'http://aurasoul.mb2.jp/pct/6th/18.png',
'http://aurasoul.mb2.jp/pct/6th/21.png',
'http://aurasoul.mb2.jp/pct/6th/24.png',
'http://aurasoul.mb2.jp/pct/6th/25.jpg',
'http://aurasoul.mb2.jp/pct/6th/26.png',
'http://aurasoul.mb2.jp/pct/6th/27.png',
'http://aurasoul.mb2.jp/pct/6th/28.png',
'http://aurasoul.mb2.jp/pct/6th/29.png',
'http://aurasoul.mb2.jp/pct/6th/30.jpg',
'http://aurasoul.mb2.jp/pct/6th/31.png',
'http://aurasoul.mb2.jp/pct/6th/33.jpg',
'http://aurasoul.mb2.jp/pct/6th/35.png',
'http://aurasoul.mb2.jp/pct/6th/36.png',
'http://aurasoul.mb2.jp/pct/6th/38.png',
'http://aurasoul.mb2.jp/pct/6th/41.png',
'http://aurasoul.mb2.jp/pct/6th/43.jpg',
'http://aurasoul.mb2.jp/pct/6th/44.jpg',
'http://aurasoul.mb2.jp/pct/6th/45.png',
'http://aurasoul.mb2.jp/pct/6th/46.png',
'http://aurasoul.mb2.jp/pct/6th/6.png',
'http://aurasoul.mb2.jp/pct/6th/9.png',
'http://aurasoul.mb2.jp/pct/6th/rel_2540.jpg',
'http://aurasoul.mb2.jp/pct/6th/rel_5672.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5771.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5773.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5804.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5835.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5877.jpg',
'http://aurasoul.mb2.jp/pct/6th/rel_5891.jpg',
'http://aurasoul.mb2.jp/pct/6th/rel_5898.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5901.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5902.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5905.jpg',
'http://aurasoul.mb2.jp/pct/6th/rel_5908.jpg',
'http://aurasoul.mb2.jp/pct/6th/rel_5914.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5916.jpg',
'http://aurasoul.mb2.jp/pct/6th/rel_5917.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5919.jpg',
'http://aurasoul.mb2.jp/pct/6th/rel_5920.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5921.jpg',
'http://aurasoul.mb2.jp/pct/6th/rel_5924.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5929.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5930.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5933.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5934.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5936.jpg',
'http://aurasoul.mb2.jp/pct/6th/rel_5939.jpg',
'http://aurasoul.mb2.jp/pct/6th/rel_5942.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5943.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5948.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5949.jpg',
'http://aurasoul.mb2.jp/pct/6th/rel_5953.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5959.jpg',
'http://aurasoul.mb2.jp/pct/6th/rel_5970.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5989.png',
'http://aurasoul.mb2.jp/pct/6th/rel_5999.jpg',
'http://aurasoul.mb2.jp/pct/6th/rel_6001.jpg',
'http://aurasoul.mb2.jp/pct/6th/rel_6012.png',
'http://aurasoul.mb2.jp/pct/6th/rel_6016.png',
'http://aurasoul.mb2.jp/pct/6th/rel_6025.png',


'http://aurasoul.mb2.jp/pct/marimo4.jpeg',
'http://aurasoul.mb2.jp/pct/marimo5.jpeg=2',
'http://aurasoul.mb2.jp/pct/marimo6.jpeg=4',
'http://aurasoul.mb2.jp/pct/marimo7.jpg=8',
'http://aurasoul.mb2.jp/pct/marimo8.jpg=4',
'http://aurasoul.mb2.jp/pct/marimo10.jpg=12',
'http://aurasoul.mb2.jp/pct/marimo11.jpg=1',
'http://aurasoul.mb2.jp/pct/marimo13.jpg=2',
'http://aurasoul.mb2.jp/pct/5th/rel_1479.jpg=',
'http://aurasoul.mb2.jp/pct/5th/rel_1512.jpg=',
'http://aurasoul.mb2.jp/pct/5th/rel_1512.jpg=',
'http://aurasoul.mb2.jp/pct/5th/rel_1549.jpg=',
'http://aurasoul.mb2.jp/pct/5th/rel_1514.jpg=',
'http://aurasoul.mb2.jp/pct/5th/rel_1525.jpg=',
'http://aurasoul.mb2.jp/pct/5th/rel_1465.png=',
'http://aurasoul.mb2.jp/pct/5th/rel_1475.png=',
'http://aurasoul.mb2.jp/pct/5th/rel_1555.png=',
'http://aurasoul.mb2.jp/pct/5th/rel_1551.png=',
'http://aurasoul.mb2.jp/pct/5th/rel_1554.jpg=',
'http://aurasoul.mb2.jp/pct/5th/rel_1511.jpg=',
'http://aurasoul.mb2.jp/pct/5th/rel_1534.jpg=',

'http://aurasoul.mb2.jp/pct/4shuunenn/rel_3892.jpg=',
'http://aurasoul.mb2.jp/pct/4shuunenn/rel_3893.jpg=',
'http://aurasoul.mb2.jp/pct/4shuunenn/rel_3899.jpg=',
'http://aurasoul.mb2.jp/pct/4shuunenn/rel_3952.jpg=',
'http://aurasoul.mb2.jp/pct/4shuunenn/a0efea88_640.gif=',
'http://aurasoul.mb2.jp/pct/4shuunenn/fbce047a_640.jpg=',
'http://aurasoul.mb2.jp/pct/4shuunenn/rel_4048.jpg=',
'http://aurasoul.mb2.jp/pct/4shuunenn/rel_3891.png=',
'http://aurasoul.mb2.jp/pct/4shuunenn/rel_4056.png=',
'http://aurasoul.mb2.jp/pct/4shuunenn/rel_3975.jpg=',
'http://aurasoul.mb2.jp/pct/4shuunenn/rel_4109.png=',
'http://aurasoul.mb2.jp/pct/4shuunenn/rel_4181.jpg=',
'http://aurasoul.mb2.jp/pct/4shuunenn/rel_3928.jpg=',
'http://aurasoul.mb2.jp/pct/4shuunenn/rel_3997.jpg=',
'http://aurasoul.mb2.jp/pct/4shuunenn/rel_3899.jpg=',
'http://aurasoul.mb2.jp/pct/4shuunenn/rel_3920.jpg=',
'http://aurasoul.mb2.jp/pct/4shuunenn/rel_4019.png=',
'http://aurasoul.mb2.jp/pct/4shuunenn/rel_4150.jpg=',
'http://aurasoul.mb2.jp/pct/4shuunenn/rel_4028.png=',
'http://aurasoul.mb2.jp/pct/4shuunenn/rel_3884.jpg=',
'http://aurasoul.mb2.jp/pct/4shuunenn/rel_4006.jpg=',
'http://aurasoul.mb2.jp/pct/3shuunenn/rel_20768.jpg=',
'http://aurasoul.mb2.jp/pct/3shuunenn/rel_20810.jpg=',
'http://aurasoul.mb2.jp/pct/3shuunenn/rel_20777.jpg=',
'http://aurasoul.mb2.jp/pct/3shuunenn/rel_20832.png=',
'http://aurasoul.mb2.jp/pct/3shuunenn/rel_20829.png=',
'http://aurasoul.mb2.jp/pct/3shuunenn/rel_20759.png=',
'http://aurasoul.mb2.jp/pct/3shuunenn/rel_20706.jpg=',
'http://aurasoul.mb2.jp/pct/3shuunenn/rel_20837.png=',
'http://aurasoul.mb2.jp/pct/3shuunenn/rel_20763.jpg=',
'http://aurasoul.mb2.jp/pct/3shuunenn/rel_20838.png=',
'http://aurasoul.mb2.jp/pct/3shuunenn/rel_20766.jpg=',
'http://aurasoul.mb2.jp/pct/3shuunenn/rel_20822.jpg=',
'http://aurasoul.mb2.jp/pct/3shuunenn/rel_20881.png=',

'http://aurasoul.mb2.jp/pct/marimo.GIF'


);

# 次の画像に切り替える間隔（秒）
my $renewsec = 1*60*60;

# 画像をランダムに選択
my $rand = 1 + int($time / $renewsec) % @images;
	foreach(@images){
		$i++;
		my($file,$target) = split(/=/,$_);
				if($i == $rand || $nextflag){
				if($target && $target ne $thismonth){ $nextflag = 1; next; }
			($imgurl,$tail) = split(/\./,$file);
			$imgfile = $file;

				# スマフォ板
				if($main::device{'smart_flag'}){
					
				}
				# デスクトップ版
				else{
					$css_text .= qq(.body1{background-image:url($file);background-repeat:no-repeat;background-position:100% 0%;});
				}
			last;
		}
	}


$line .= qq(<span class="guide">※このページの<a href="$imgfile">画像</a>は、メビウスリングの誕生日にいただいたお祝い絵などです。</span>);


# 小さい画像がなければ作成
#if(-e "$imgfile" && !$alocal_mode){ require "${int_dir}"; &csize($imgfile,$tail,"500","300"); }

# 整形
#my $style = qq( style="width:300px;height:300px;") if($alocal_mode);
#$line = qq(<div class="image"><h2>イメージ</h2><a href="$imgfile" class="topimage"><img src="$imgfile" class="topimage" alt="ＴＯＰを飾るランダム画像"$style></a></div>);

if(Mebius::alocal_judge()){
	if($in{'all'}){
			foreach(@images){
				my($file,$target) = split(/=/,$_);
				$line .= qq(<img src="$file" class="topimage" alt="ＴＯＰを飾るランダム画像"$style>);
			}
	}
	else{ $line .= qq(<a href="$script?all=1">全ての画像(ローカル)</a>); }
}

# リターン
($line,$imgfile);


}

#-----------------------------------------------------------
# Twitter
#-----------------------------------------------------------
sub main_top_get_twitter{


# リターン
if($kflag){ return(); }

return();

my $line = qq(
<h2>Twitter ( 管理人 ) </h2>
<script type="text/javascript" src="http://widgets.twimg.com/j/2/widget.js"></script>
<script type="text/javascript">
<!--
new TWTR.Widget({
  version: 2,
  type: 'profile',
  rpp: 2,
  interval: 6000,
  width: 700,
  height: 300,
  theme: {
    shell: {
      background: '#7799ff',
      color: '#000000'
    },
    tweets: {
      background: '#ffffff',
      color: '#000000',
      links: '#0000ff'
    }
  },
  features: {
    scrollbar: false,
    loop: false,
    live: false,
    hashtags: true,
    timestamp: true,
    avatars: false,
    behavior: 'all'
  }
}).render().setUser('aurasoul').start();
-->
</script><br>
※<a href="http://twitter.com/aurasoul">興味のある方は Twitterに登録して、ぜひ \@aurasoul 宛に「メビウスリング！」とツイートしてください。</a> ( <a href="http://twitter.com/aurasoul/mebius">→メビウスリスト</a> )

);

$line;

}



1;
