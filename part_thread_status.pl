
use strict;
package main;

#-----------------------------------------------------------
# 削除済みページ
#-----------------------------------------------------------
sub thread_get_deletelock{

# 宣言
my($type,$main_thread,$use_thread) = @_;
my($delman,$delday,$deltime,$reason) = split(/=/,$main_thread->{'delete_data'});
my($flag,$deleted_text);
our($css_text,$repairform,$khrtag,$status_flag,$now_url,$guide_url);
our($title,$server_domain,$sub_title,$int_dir,$xclose,$k_access,%category,$moto);

# カテゴリ設定を取得
my($init_bbs) = Mebius::BBS::init_bbs_parmanent($moto);

	# CSS定義(予約削除)
	if($type =~ /LIGHT/){
		$css_text .= qq(
		div.lightdeleted{border:solid 1px #000;padding:1em;line-height:1.6em;}
		.reason{font-size:140%;}
		);
	}

	# CSS定義(完全削除)
	if($type =~ /HEAVY/){
		$css_text .= qq(
		a.white{color:#00f;}
		div.deleted{border:solid 1px #000;padding:1.5em 2.0em;}
		ul{margin:1em 0em;font-size:130%;}
		li{color:#f00;}
		);
	}

# 削除理由取り込み
require "${int_dir}part_delreason.pl";
my($delreason_text,$delreason_subject) = &delreason($reason);

	# 削除理由
	if($delreason_text){ $delreason_text = qq(▼削除理由： $delreason_text<br$xclose>); }

	# タイトル定義
	if($type =~ /MOBILE/){ &thread_set_title_mobile(); }
	else{ &thread_set_title($main_thread); }

	# リンク切れの場合、修復
	if($type =~ /(LIGHT|HEAVY)/ && $ENV{'REQUEST_METHOD'} eq "GET"){
		if($type =~ /MOBILE/){ &repairform(); }
		else{ &repairform(); }
	}

	# ステータスコード
	if($type =~ /(LIGHT|HEAVY)/){
			if(!$status_flag && !$k_access){
				print qq(Status: 410 Gone\n);
				$status_flag = 1;
			}
	}

	# ページタイトルを変更
	if($type =~ /HEAVY/){ $sub_title = "削除済み記事"; }

	# 予約削除の場合
	if($type =~ /LIGHT/){
			my($how_delete_reserve) = shift_jis(Mebius::second_to_howlong({ TopUnit => 1 } , $main_thread->{'delete_reserve_time'} - time));
		if($delreason_text){ $delreason_text = qq(<strong class="reason">$delreason_text</strong><br$xclose>); }
		$deleted_text .= qq(
		<div class="lightdeleted">
		<span class="red">この記事は、$titleのメニューから削除済みです。<br$xclose>
		あと $how_delete_reserve で記事本体も完全に削除されます。<br$xclose><br$xclose>
		$delreason_text
		●削除者： $delman / ●実行日時： $delday<br$xclose><br$xclose>
		<a href="$init_bbs->{'report_thread_href'}">→削除依頼をチェック</a> / 
		<a href="${guide_url}%BA%EF%BD%FC%A3%D1%A1%F5%A3%C1">→削除Ｑ＆Ａ</a></span>
		</div>
		<br$xclose>
		);
		return($deleted_text);
	}

	# 完全削除の場合
	if($type =~ /HEAVY/){

		my $print = qq(
		<div class="deleted">
		<h1><a href="${guide_url}410">410 Gone</a> - 削除済み -</h1>
		<strong style="font-size:140%;">$delreason_text</strong><br$xclose>
		●削除者： $delman ●実行日時： $delday<br$xclose>
		<br$xclose>
		次のようなルール違反がなかったかどうか、お確かめください。
		<ul>
		<li>個人情報の掲載。</li>
		<li>マナー違反。</li>
		<li>重複記事 / カテゴリ違い。</li>
		<li>個人的な記事/参加者の限定。</li>
		<li>恋愛系、出会い系利用。</li>
		<li>文字数稼ぎ、宣伝などの迷惑行為。</li>
		<li>記事のテーマが曖昧。テーマが二つ以上ある。</li>
		<li>必要な注意書き、チェックの不足。</li>
		<li>ローカルルール違反。</li>
		</ul>
		詳しくは<a href="${guide_url}%BF%B7%B5%AC%C5%EA%B9%C6">新規投稿のルール</a>・<a href="${guide_url}%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7">メビウスリング禁則</a>をご覧ください。<a href="${guide_url}%BA%EF%BD%FC%A3%D1%A1%F5%A3%C1">削除Ｑ＆Ａ</a>もあります。
		</div>
		);

		Mebius::Template::gzip_and_print_all({ ReadThread => 1 , read_thread_res_number => $use_thread->{'res'} },$print);

		exit;
	}



}


#-----------------------------------------------------------
# ロック中の記事
#-----------------------------------------------------------
sub thread_status_lock{

# 宣言
my($type,$delete_data,$lock_end_time) = @_;
my($delman,$delday,$deltime,$reason) = split(/=/,$delete_data);
my($lockview_line);

	# 解除時間が過ぎている場合
	if($lock_end_time && $main::time >= $lock_end_time){ return(); }

# 削除理由取り込み
require "${main::int_dir}part_delreason.pl";
my($delreason_text,$delreason_subject) = &delreason($reason);

# 表示内容 (帯)
$lockview_line .= qq(<div class="thread_status">);
$lockview_line .= qq(<a href="$main::guide_url" class="white">この記事はロック中です);
	if($delreason_text){ $lockview_line .= qq( ( $delreason_subject ) ); }
$lockview_line .= qq(</a>);

	# 解除時間
	if(time < $lock_end_time){
		my($how_lock) = Mebius::SplitTime("Get-top-unit Omit-top-time",$lock_end_time - $main::time); 
		$lockview_line .= qq( - あと$how_lockで解除されます。);
	}

$lockview_line .= qq(</div>\n);
$main::css_text .= qq(div.lock_tell{background:#fff;font-weight:normal;});

return($lockview_line);


}


1;
