
package main;

#-----------------------------------------------------------
# 携帯版 掲示板 記事検索
#-----------------------------------------------------------
sub bbs_find_mobile{

# 局所化
my($no,$sub,$res,$nam,$date,$na2,$key,$target,$alarm,$next,$back,$enwd,@log1,@log2,@log3,@wd);
my($past_checked,$now_checked,$log_divide,$hit,$encword);

# 検索最大数
$find_max = 30;
# エンコード
($encword) = Mebius::Encode("",$in{'word'});

	# アクセス振り分け
	if($in{'log'} ne ""){ $log_divide = "&log=$in{'log'}"; }
		my $postbuf_escaped = $main::postbuf;
		$postbuf_escaped =~ s/mode=kfind/mode=find/g;
		$postbuf_escaped =~ s/moto=(\w+)&?//g;
		$divide_url = "http://$server_domain/_$moto/?$postbuf_escaped";
	#if($device_type eq "desktop"){ &divide($divide_url,"desktop"); }

	# 全検索モードへ
	if($main::ch{'word'} && $main::in{'allsearch'}){
		my($encword) = Mebius::Encode("","$in{'word'}");
		Mebius::Redirect("","http://$main::server_domain${main::main_url}?mode=allsearch-p-1&word=$encword");
	}

	# タイトル定義
	if($in{'word'}) { $sub_title = "”$in{'word'}” | $title"; }
	else{ $sub_title = "記事検索 | $title";  }


require "${main::int_dir}part_indexview.pl";
my($index_line,$search_option_line,$plusform_line) = index_findmenu_set("Mobile-view",$find_max);
shift_jis($index_line,$search_option_line,$plusform_line);

my $print = qq(
<form action="$script" style="$kpadding_normal_in$kborder_bottom_in">
<div style="$ktextalign_center_in">
(*)<input type="hidden" name="mode" value="kfind"$xclose>
<input type="text" name="word" value="$main::in{'word'}" size="9" accesskey="*"$xclose>
<input type="submit" value="検索"$xclose>
<br$main::xclose>
<div>$search_option_line</div>
<div>$plusform_line</div>
</div>
</form>
$index_line
);

Mebius::Template::gzip_and_print_all({},$print);


exit;

}



1;
