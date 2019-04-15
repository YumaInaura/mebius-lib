
use strict;
use Mebius::AuthAccount;
#package main;

#-----------------------------------------------------------
# SNS アカウント一覧
#-----------------------------------------------------------
sub auth_avnewac{

# 局所化
my(%account_list);
our($body_javascript,$css_text,%in,$title,$head_link2,$head_link3,$action,$submode3,$sub_title,$footer_link,$footer_link2);

# 各種エラー
if($submode3 eq ""){ &error("ページが存在しません。"); }

# CSS定義
$css_text .= qq(
span.guide{font-size:90%;color:#080;}
);

	
	# ワード検索する場合
	if($main::in{'word'}){

		# キーワード調整
		my $keyword = $main::in{'word'};
		$keyword =~ s/(${main::auth_url}|\/|_)//g;

		(%account_list) = Mebius::Auth::AccountListFile("Get-index Keyword-search-mode Search-file",$keyword);
	}
	# ワード検索しない場合
	else{
		(%account_list) = Mebius::Auth::AccountListFile("Get-index Normal-file");
	}




# タイトル定義
$sub_title =  "アカウント一覧 - $title";
$head_link2 = " &gt; アカウント一覧";
	if($in{'word'} ne ""){
		$sub_title = "”$in{'word'}”で検索 - アカウント一覧 - $title";
		$head_link2 = qq(&gt; <a href="./aview-newac-1.html">アカウント一覧</a> );
		$head_link3 = qq(&gt; ”$in{'word'}”で検索 );
	}

	# フォーカスを当てる
	if(!exists $main::in{'word'}){
		$body_javascript = qq( onload="document.member.word.focus()");
	}


# 検索フォーム
my $form = qq(
<h2>メンバー検索</h2>
<form action="$action" name="member">
<div>
<input type="text" name="word" value="$in{'word'}">
<input type="hidden" name="mode" value="aview-newac-1">
<input type="submit" value="検索する">　
<span class="guide">*筆名、アカウント名から検索します。</span>
</div>
</form>
);

if($in{'word'} ne ""){ $form .= qq(<br><a href="aview-newac-1.html">→普通に表\示</a>); }


my $print = <<"EOM";
$footer_link
<h1>アカウント一覧</h1>
$form
<h2>一覧</h2>
<ul>
$account_list{'index_line'}
</ul><br>
$footer_link2
EOM

Mebius::Template::gzip_and_print_all({},$print);


exit;

}

1;
