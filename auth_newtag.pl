
package main;

#-----------------------------------------------------------
# 新着タグを表示
#-----------------------------------------------------------
sub auth_newtag{

# 局所化
my($tagline,$i,$link1);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# CSS定義
$css_text .= qq(
.list{word-spacing:0.5em;line-height:2.5em;font-size:90%;}
.notice1{}
.notice2{font-size:125%;font-weight:bold;}
.notice3{font-size:140%;font-weight:bold;}
.notice4{font-size:170%;font-weight:bold;}
.notice5{font-size:210%;font-weight:bold;}
.notice6{font-size:210%;font-weight:bold;color:#080;}
.notice7{font-size:210%;font-weight:bold;color:#f55;}
);

# マイタグファイルを開く
my $openfile1 = "${auth_log_directory}newtag.cgi";
open(NEWTAG_IN,"<","$openfile1");
	while(<NEWTAG_IN>){

		my($num,$tag) = split(/<>/,$_);
		my($class);
		$i++;


			if($main::device_type eq "mobile" && $i > 100){ last; }

			if(Mebius::Fillter::heavy_fillter(utf8_return($tag))){ next; }

		my $enctag2 = $tag;
		$enctag2 =~ s/([^\w])/'%' . unpack("H2" , $1)/eg;
		$enctag2 =~ tr/ /+/;

		if($num < 10){ }
		elsif($num < 25){ $class = qq( class="notice2"); }
		elsif($num < 50){ $class = qq( class="notice3"); }
		elsif($num < 100){ $class = qq( class="notice4"); }
		elsif($num < 250){ $class = qq( class="notice5"); }
		elsif($num < 500){ $class = qq( class="notice6"); }
		else{ $class = qq( class="notice7"); }

		$tagline .= qq(<a href="./tag-word-${enctag2}.html"$class>$tag</a>\n);
		#if($key eq "2"){ $tagline .= qq(<span class="red">(削除済)</span>); }
	}
close(NEWTAG_IN);

# リスト整形
#if($tagline ne ""){ $tagline = qq(<h2>新着一覧</h2><ul>$tagline</ul>); }
if($tagline ne ""){ $tagline = qq(<h2>新着一覧</h2><div class="list">$tagline</div>); }

# タイトル定義
$sub_title = "新着タグ - $title";
$head_link3 = " &gt; 新着タグ ";

# タグ検索フォームを取得
&get_schform();

# ナビゲーションリンク
my($navilink);
$navilink .= qq(<a href="JavaScript:history.go\(-1\)">前の画面に戻る</a>);
if($idcheck){ $navilink .= qq( - <a href="./$pmfile/tag-view">タグを登録する</a>); }

# HTML
my $print = qq(
$footer_link
<h1>新着タグ - $title</h1>
$navilink
$schform
$form
$tagline
$footer_link2
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;
