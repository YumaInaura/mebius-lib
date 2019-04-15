
use strict;
use Mebius::AuthAccount;
package main;
use Mebius::Export;

#-----------------------------------------------------------
# SNS アカウント一覧
#-----------------------------------------------------------
sub auth_avnewac{

# 局所化
my(%account_list);
my $html = new Mebius::HTML;
my $sns_path = new Mebius::SNS::Path;
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
my($line,$hit,@BCL,$all_account_dbi);
our($title,$action,$submode3);

# 各種エラー
	if($submode3 eq ""){ &error("ページが存在しません。[anwac]"); }

# CSS定義
my $css_text .= qq(
span.guide{font-size:90%;color:#080;}
);

	if(exists $param->{'word'}){
		$all_account_dbi = Mebius::SNS::Account->fetchrow_main_table({ account => "LIKE %$param->{'word'}%" , name => ["LIKE","%$param->{'word'}%"] },{ OR => 1 } );
	} else {
		my $border_time = time - 31*24*60*60;
		$all_account_dbi = Mebius::SNS::Account->fetchrow_main_table({ firsttime => [">",$border_time] });
	}



my @sorted_all_account = sort { $b->{'firsttime'} <=> $a->{'firsttime'} } @$all_account_dbi;

	foreach my $data (@sorted_all_account){

			#if(exists $param->{'word'} && $data->{'account'} !~ /$param->{'word'}/ && $data->{'name'} !~ /$param->{'word'}/){
			#	next;
			#}

		$hit++;
		$line .= qq(<li>);
		$line	.= $html->href($sns_path->account_url($data->{'account'}),"$data->{'name'} \@$data->{'account'}");
		$line .= qq( ) . Mebius::Time->how_before($data->{'firsttime'});
			if($my_account->{'master_flag'}){
				$line .= qq( ) . e($data->{'remain_email'});
			}
		$line .= qq(</li>);
			if($hit >= 100 && !$my_account->{'master_flag'}){ last; }

	}

	# ワード検索する場合
	#if($main::in{'word'}){

		# キーワード調整
	#	my $keyword = $main::in{'word'};
	#	$keyword =~ s/(${main::auth_url}|\/|_)//g;

	#	(%account_list) = Mebius::Auth::AccountListFile("Get-index Keyword-search-mode Search-file",$keyword);
	#}
	# ワード検索しない場合
	#else{
	#	(%account_list) = Mebius::Auth::AccountListFile("Get-index Normal-file");
	#}



# タイトル定義
my $sub_title =  "アカウント一覧 - $title";

	if($param->{'word'} ne ""){
		$sub_title = "”$param->{'word'}”で検索 - アカウント一覧 - $title";
		push @BCL , { url => "./aview-newac-1.html" , title => "アカウント一覧" };
		push @BCL , "”$param->{'word'}”で検索";
	} else {
		push @BCL , "アカウント一覧";
	}

	# フォーカスを当てる
	#if(!exists $main::in{'word'}){
	#	$body_javascript = qq( onload="document.member.word.focus()");
	#}


# 検索フォーム
my $form = qq(
<h2>メンバー検索</h2>
<form action="$action" name="member">
<div>
<input type="hidden" name="mode" value="aview-newac-1">
<input type="text" name="word" value=").e($param->{'word'}).qq(">
<input type="submit" value="検索する">　
<span class="guide">*筆名、アカウント名から検索します。</span>
</div>
</form>
);

		if($param->{'word'} ne ""){ $form .= qq(<br><a href="aview-newac-1.html">→普通に表\示</a>); }

my $top_links = Mebius::SNS->my_navigation_links({ Top => 1 });
my $bottom_links = Mebius::SNS->my_navigation_links({ Bottom => 1 });


my $print = <<"EOM";
$top_links
<h1>アカウント一覧</h1>
$form
<h2>一覧</h2>
<ul>
$line
</ul><br>
$bottom_links
EOM

Mebius::Template::gzip_and_print_all({ Title => $sub_title , source => "utf8" , BCL => \@BCL },$print);


exit;

}

1;
