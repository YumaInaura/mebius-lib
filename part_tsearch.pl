
use Mebius::Text;
use strict;

#-----------------------------------------------------------
# 記事内検索
#-----------------------------------------------------------
sub bbs_tsearch{

# 局所化
my($keyword,$type,$name,$comment,$id,$account,$agent,$host2) = @_;
my($name_flag,$comment_flag,$id_flag,$account_flag,$host_flag,$agent_flag);
my($vf_ram,$hit,$return_comment,$return_name,$retrun_id,$name_hit,$id_hit,$account_hit,$agent_hit,$host_hit,$comment_split,$i_keyword,$hit_flag,%comment_hit,$hit_flag_buffer);
my($my_account) = Mebius::my_account();
my($my_admin) = Mebius::my_admin() 	if(Mebius::Admin::admin_mode_judge());
our(%in);

my $max_keyword_num = 3;

	# 検索指定がない場合、全代入
	if($in{'nam'} eq "" && $in{'com'} eq "" && $in{'id'} eq "" && $in{'ac'} eq "" && $in{'wdage'} eq "" && $in{'wdhost'} eq ""){
		$name_flag = $comment_flag = $id_flag = $account_flag = 1;
			if(Mebius::Admin::admin_mode_judge()){ $agent_flag = $host_flag = 1; }
	}

	# 検索対象にするデータ
	else{
		$name_flag = $in{'nam'};
		$comment_flag = $in{'com'};
		$id_flag = $in{'id'};
		$account_flag = $in{'ac'};
		$host_flag = $in{'wdhost'};
		$agent_flag = $in{'wdage'};
	}


	# ▼本文から検索
	if($comment_flag && $comment){

		my($high_lighted_comment,$hit_comment_num) = Mebius::Search::high_light_include_br_tag($comment,$keyword,{ OR => 1 , SJIS => 1 , max_keyword_num => $max_keyword_num });

			if($high_lighted_comment){
				$return_comment = $high_lighted_comment;
				$hit += $hit_comment_num;
			} else {
				$return_comment = $comment;
			}
	}

	# キーワードをスペース区切で展開する
	foreach my $keyword_split (split(/\s|　/,$keyword)){

		# キーワードの個数を判定
		if($keyword_split){ $i_keyword++; } else { next; }

		# キーワードをアジャスト
		my($keyword_split_adjusted) = Mebius::Text::KeywordAdjust(undef,$keyword_split);

			# ▼筆名から検索
			if($name_flag && $name ne ""){
					if(index($name,$keyword_split) >= 0) {
						$hit++;
						$name_hit = 1;
					}
			}

			# ▼ＩＤから検索
			if($id_flag && $id){
				my $keyword2 = $keyword_split;
				$keyword2 =~ s/★//g;
					if (index($id,$keyword2) >= 0) {
						$hit++;
						$id_hit = 1;
					}
			}

			# ▼アカウント名から検索
			if($account_flag && $account && $keyword_split =~ /^[0-9a-z]+$/){
					if(index($account,$keyword_split) >= 0) {
						$hit++;
						$account_hit = 1;
					}
			}


			# ▼ホスト名から検索
			if($host_flag && $host2 ne "" && Mebius::Admin::admin_mode_judge() && $my_admin->{'master_flag'}){

					if(index($host2,$keyword_split) >= 0) {
						$hit++;
						$host_hit = 1;
					}
			}

			# ▼ＵＡから検索
			if($agent_flag && $agent ne "" && Mebius::Admin::admin_mode_judge()){
					if(index($agent,$keyword_split) >= 0) {
						$hit++;
						$agent_hit = 1;
					}
			}


	}


	# ヒットしたかどうかを最終判定
	if($hit && $hit >= $i_keyword){		$hit_flag = 1;
	}

	#if($hit){
	#	$hit_flag = 1;
	#}


{ hit => $hit_flag , high_lighted_comment => $return_comment , name_hit => $name_hit , id_hit => $id_hit , account_hit => $account_hit , host_hit => $host_hit };

#return($hit_flag,$return_comment,$name_hit,$id_hit,$account_hit,$agent_hit,$host_hit);

}


#-----------------------------------------------------------
# 検索処理の基本チェック
#-----------------------------------------------------------
sub tsearch_check_keyword{

# 宣言
my($keyword) = @_;
my($flag,$encword);
my($param) = Mebius::query_single_param();
our($moto);

# キーワードチェック
$keyword =~ s/( |　|<br>)//g;
	#if(length($keyword) < 2*1){ $flag = qq(検索できませんでした。キーワードは全角１文字以上、２００文字以内で入力してください。); }
	if(length($keyword) > 2*200){ $flag = qq(検索できませんでした。キーワードは全角１文字以上、２００文字以内で入力してください。); }

# エンコード
my($encword) = Mebius::Encode("",$param->{'word'});

	# Canonical属性
	if(exists $param->{'word'}){ our $canonical = e("/_$moto/?mode=view&amp;no=$param->{'no'}&amp;word=$encword"); }

# CSS追加
our $css_text .= qq(
a.hit,strong.hit{font-weight:bold;background-color:#fc0;color:#fff;padding:0.15em 0.5em;}
a.hit:hover,strong.hit:hover{color:#aaa !important;}
);


return($flag);

}



#-----------------------------------------------------------
# 検索フォームをゲット
#-----------------------------------------------------------
sub tsearch_get_vfcheckarea{

# 局所化
my($type,$round) = @_;
my($line,$ck1,$ck2,$ck3,$ck4,$checked_ua,$checked_host,$checked_deleted);
my($my_admin) = Mebius::my_admin();

if($main::in{'com'}){ $ck1 = " checked"; }
if($main::in{'nam'}){ $ck2 = " checked"; }
if($main::in{'id'}){ $ck3 = " checked"; }
if($main::in{'ac'}){ $ck4 = " checked"; }
if($main::in{'wdage'}){ $checked_ua = " checked"; }
if($main::in{'wdhost'}){ $checked_host = " checked"; }
if($main::in{'wddeleted'}){ $checked_deleted = " checked"; }

$line .= qq(<input type="checkbox" name="com" value="1" id="t_comment$round"$ck1><label for="t_comment$round">本文</label>);
$line .= qq(<input type="checkbox" name="nam" value="1"  id="t_handle$round"$ck2><label for="t_handle$round">筆名</label>\n);
$line .= qq(<input type="checkbox" name="id" value="1" id="t_id$round"$ck3><label for="t_id$round">ＩＤ</label>\n);
$line .= qq(<input type="checkbox" name="ac" value="1" id="t_account$round"$ck4><label for="t_account$round">アカウント</label>\n);

	# 管理者用
	if(Mebius::Admin::admin_mode_judge()){
		$line .= qq(<input type="checkbox" name="wdage" value="1" id="t_ua"$checked_ua><label for="t_ua">ＵＡ</label>\n);
			if($my_admin->{'master_flag'}){
				$line .= qq(<input type="checkbox" name="wdhost" value="1" id="t_host"$checked_host> <label for="t_host">ホスト名</label>\n);
			}
	}

return($line);

}

1;
