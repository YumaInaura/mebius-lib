
package main;
use strict;
use Mebius::Export;

#-----------------------------------------------------------
# 削除理由の表記 ( 任意のものを抽出する )
#-----------------------------------------------------------
sub delreason{

# 宣言
my($select,$type) = @_;
my($reason_text,$reason_subject,$reason_comment,$reason_operation);

# 基本設定を取得
my($kind_list_for_thread) = Mebius::Reason::kind_list_for_thread();

	# 理由を展開
	foreach(keys %{$kind_list_for_thread}){

		my $hash = $kind_list_for_thread->{$_};

			if($_ eq $select){

				($reason_subject,$reason_comment,$reason_operation) = shift_jis($hash->{'title'},$hash->{'guide'},$hash->{'operation'});

					if($type ne "ONLY"){ $reason_text .= qq($reason_subject); }
					if($hash->{'guide'} && $type ne "SUBJECT"){ $reason_text .= qq( → $reason_comment); }
					if($hash->{'guide_url'}){
						$reason_text .= qq( \(<a href=").e($hash->{'guide_url'}).q(">→ヘルプ</a> \));
					}

			} else {
				0;
			}
	}

return($reason_text,$reason_subject,$reason_comment,$reason_operation);

}




1;

