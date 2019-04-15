
use strict;
package main;
use Mebius::Export;

#-----------------------------------------------------------
# �G���[�\�� - strict
#-----------------------------------------------------------
sub do_error{

# �錾
my $use = shift if(ref $_[0] eq "HASH");
my($text,$code,$plus,$type) = @_;
my($my_use_device) = Mebius::my_use_device();
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();
my($textarea_postdata,$admin_text,$print,$http_header,$status_code_name,$admin_view_data);
our($no_headerset,$jump_url,$lockflag,$head_javascript,$headflag,$status_flag,$k_access,$css_text,$head_link3,$fook_error,$home,%done,$error_message_all);
our($postbuf,$postflag);

	# �G���[���A�����b�N
	if($lockflag) { main::unlock($lockflag); }

	if(ref $text eq "ARRAY"){

			foreach my $this_text (@$text){

				# �R�[�h�����ϊ�
				g_shift_jis($this_text);

				$error_message_all .= qq(<li>$this_text</li>);

			}

		$error_message_all = qq(<ul>$error_message_all</ul>);

	} else {

		# �R�[�h�����ϊ�
		$error_message_all = $text;
		g_shift_jis($error_message_all);

	}

# ���[�v�֎~
	if($done{'error'}){ $http_header .= "Content-type:text/html\n\n"; $http_header .= "Error : $text <a href=\"/\">Back</a>"; exit; }
$done{'error'}++;

# ���ݒ�
$no_headerset = 1;
$jump_url = undef;

	# �g�уG���[��
	#if($my_use_device->{'mobile_flag'}){ &kerror(@_); }

	# �����N�؂�̎����C��
	#if($type !~ /Not-repair/ && !$use->{'NotRepairURL'} && $ENV{'REQUEST_METHOD'} eq "GET" && !$not_repair_url_flag && !Mebius::Admin::admin_mode_judge() ){ &repairform(); }

	# �w�b�_�������Ă��Ȃ���΃X�e�[�^�X�R�[�h��Ԃ�
	if(!$headflag && !$status_flag){

			# �����w�肳��Ă��Ȃ��ꍇ
			if($code eq "" && $ENV{'REQUEST_METHOD'} eq "GET"){
				$code = "404";
			}

			# ���������̃R�[�h�ɕ�����⊮
			if($code eq "503"){
				$status_code_name = "Service Temporarily Unavailable";
			}
			elsif($code eq "410"){
				$code = "410";
				$status_code_name = "Gone";
			}
			elsif($code eq "401"){
				$code = "401";
				$status_code_name = "Unauthorized";
			}
			elsif($code eq "404"){
				$code = "404";
				$status_code_name = "NotFound";
			}

			# �R�[�h��ǂݎ��Ȃ��[��
			if($code eq "none" || (($k_access || $ENV{'HTTP_USER_AGENT'} =~ /PlayStation Vita/) && !Mebius::Device::bot_judge())){
				0;
			# �ǂݎ���[��
			} elsif($code){
				$http_header .= "Status: $code $status_code_name\n";
			}

		$status_flag = 1;
	}


# ���`
if($plus){ $plus = qq(<div class="plus">$plus</div>); }

# CSS��`
$css_text .= qq(
div.error{line-height:1.4;}
.footerlink{margin-top:1em;}
.plus{margin:1em 0em;}
div.back_links{margin:1em 0em;}
textarea.postdata{width:70%;height:200px;}
);

# �薼
$head_link3 = qq( &gt; �G���[ );

# Javascript���N�����Ȃ�
$head_javascript = undef;

	# ���e��
	if($main::postflag && $main::in{'comment'}){
		my $textarea_comment = $main::in{'comment'};
		$textarea_comment =~ s/<br>/\n/g;
		$textarea_postdata .= qq(<div>\n);
		$textarea_postdata .= qq(<h2$main::kstyle_h2>���M���e ( �������܂�Ă��܂��� )</h2>\n);
		$textarea_postdata .= qq(<textarea class="postdata">$textarea_comment</textarea></div>\n);
	}


# ���`
my $brnum = ($text =~ s/<br>/$&/g);
my $br = qq(<br><br>) if($brnum >= 2);

	# �Ǘ��җp
	if($my_account->{'master_flag'}){
		$admin_view_data = qq(<br><br>$postbuf);
		($admin_text) = Mebius::escape("",$text);
		$admin_text = qq(<hr> $admin_text);
	}


# �G���[�g�s�l�k��\��
$print .= qq(<div class="error"><strong class="red">�G���[);
	if($code){ $print .= qq! $code $status_code_name !; }
$print .= qq(
�F $br$error_message_all$admin_text</strong>$admin_view_data</div>
$plus
$textarea_postdata
<div class="back_links">
<a href="JavaScript:history.go(-1)">�O�̉�ʂ�</a> / <a href="./">�R���e���c�s�n�o</a> / <a href="$home">�s�n�o�y�[�W�ɖ߂�</a> / <a href="$basic_init->{'mailform_url'}">�Ǘ��҂ɘA�� (���[���t�H�[��)</a>);

	if($ENV{'REQUEST_METHOD'} eq "POST"){
		$print .= qq( / <a href="mailto:$basic_init->{'admin_email'}">�Ǘ��҂ɘA�� (���[��)</a>);
	}

$print .= qq(</div>);

Mebius::Template::gzip_and_print_all({ http_header => $http_header , SimpleSource => 1 , BodyPrint => 1 , Title => "�G���[" },$print);

exit;

}


1;

