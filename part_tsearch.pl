
use Mebius::Text;
use strict;

#-----------------------------------------------------------
# �L��������
#-----------------------------------------------------------
sub bbs_tsearch{

# �Ǐ���
my($keyword,$type,$name,$comment,$id,$account,$agent,$host2) = @_;
my($name_flag,$comment_flag,$id_flag,$account_flag,$host_flag,$agent_flag);
my($vf_ram,$hit,$return_comment,$return_name,$retrun_id,$name_hit,$id_hit,$account_hit,$agent_hit,$host_hit,$comment_split,$i_keyword,$hit_flag,%comment_hit,$hit_flag_buffer);
my($my_account) = Mebius::my_account();
my($my_admin) = Mebius::my_admin() 	if(Mebius::Admin::admin_mode_judge());
our(%in);

my $max_keyword_num = 3;

	# �����w�肪�Ȃ��ꍇ�A�S���
	if($in{'nam'} eq "" && $in{'com'} eq "" && $in{'id'} eq "" && $in{'ac'} eq "" && $in{'wdage'} eq "" && $in{'wdhost'} eq ""){
		$name_flag = $comment_flag = $id_flag = $account_flag = 1;
			if(Mebius::Admin::admin_mode_judge()){ $agent_flag = $host_flag = 1; }
	}

	# �����Ώۂɂ���f�[�^
	else{
		$name_flag = $in{'nam'};
		$comment_flag = $in{'com'};
		$id_flag = $in{'id'};
		$account_flag = $in{'ac'};
		$host_flag = $in{'wdhost'};
		$agent_flag = $in{'wdage'};
	}


	# ���{�����猟��
	if($comment_flag && $comment){

		my($high_lighted_comment,$hit_comment_num) = Mebius::Search::high_light_include_br_tag($comment,$keyword,{ OR => 1 , SJIS => 1 , max_keyword_num => $max_keyword_num });

			if($high_lighted_comment){
				$return_comment = $high_lighted_comment;
				$hit += $hit_comment_num;
			} else {
				$return_comment = $comment;
			}
	}

	# �L�[���[�h���X�y�[�X��؂œW�J����
	foreach my $keyword_split (split(/\s|�@/,$keyword)){

		# �L�[���[�h�̌��𔻒�
		if($keyword_split){ $i_keyword++; } else { next; }

		# �L�[���[�h���A�W���X�g
		my($keyword_split_adjusted) = Mebius::Text::KeywordAdjust(undef,$keyword_split);

			# ���M�����猟��
			if($name_flag && $name ne ""){
					if(index($name,$keyword_split) >= 0) {
						$hit++;
						$name_hit = 1;
					}
			}

			# ���h�c���猟��
			if($id_flag && $id){
				my $keyword2 = $keyword_split;
				$keyword2 =~ s/��//g;
					if (index($id,$keyword2) >= 0) {
						$hit++;
						$id_hit = 1;
					}
			}

			# ���A�J�E���g�����猟��
			if($account_flag && $account && $keyword_split =~ /^[0-9a-z]+$/){
					if(index($account,$keyword_split) >= 0) {
						$hit++;
						$account_hit = 1;
					}
			}


			# ���z�X�g�����猟��
			if($host_flag && $host2 ne "" && Mebius::Admin::admin_mode_judge() && $my_admin->{'master_flag'}){

					if(index($host2,$keyword_split) >= 0) {
						$hit++;
						$host_hit = 1;
					}
			}

			# ���t�`���猟��
			if($agent_flag && $agent ne "" && Mebius::Admin::admin_mode_judge()){
					if(index($agent,$keyword_split) >= 0) {
						$hit++;
						$agent_hit = 1;
					}
			}


	}


	# �q�b�g�������ǂ������ŏI����
	if($hit && $hit >= $i_keyword){		$hit_flag = 1;
	}

	#if($hit){
	#	$hit_flag = 1;
	#}


{ hit => $hit_flag , high_lighted_comment => $return_comment , name_hit => $name_hit , id_hit => $id_hit , account_hit => $account_hit , host_hit => $host_hit };

#return($hit_flag,$return_comment,$name_hit,$id_hit,$account_hit,$agent_hit,$host_hit);

}


#-----------------------------------------------------------
# ���������̊�{�`�F�b�N
#-----------------------------------------------------------
sub tsearch_check_keyword{

# �錾
my($keyword) = @_;
my($flag,$encword);
my($param) = Mebius::query_single_param();
our($moto);

# �L�[���[�h�`�F�b�N
$keyword =~ s/( |�@|<br>)//g;
	#if(length($keyword) < 2*1){ $flag = qq(�����ł��܂���ł����B�L�[���[�h�͑S�p�P�����ȏ�A�Q�O�O�����ȓ��œ��͂��Ă��������B); }
	if(length($keyword) > 2*200){ $flag = qq(�����ł��܂���ł����B�L�[���[�h�͑S�p�P�����ȏ�A�Q�O�O�����ȓ��œ��͂��Ă��������B); }

# �G���R�[�h
my($encword) = Mebius::Encode("",$param->{'word'});

	# Canonical����
	if(exists $param->{'word'}){ our $canonical = e("/_$moto/?mode=view&amp;no=$param->{'no'}&amp;word=$encword"); }

# CSS�ǉ�
our $css_text .= qq(
a.hit,strong.hit{font-weight:bold;background-color:#fc0;color:#fff;padding:0.15em 0.5em;}
a.hit:hover,strong.hit:hover{color:#aaa !important;}
);


return($flag);

}



#-----------------------------------------------------------
# �����t�H�[�����Q�b�g
#-----------------------------------------------------------
sub tsearch_get_vfcheckarea{

# �Ǐ���
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

$line .= qq(<input type="checkbox" name="com" value="1" id="t_comment$round"$ck1><label for="t_comment$round">�{��</label>);
$line .= qq(<input type="checkbox" name="nam" value="1"  id="t_handle$round"$ck2><label for="t_handle$round">�M��</label>\n);
$line .= qq(<input type="checkbox" name="id" value="1" id="t_id$round"$ck3><label for="t_id$round">�h�c</label>\n);
$line .= qq(<input type="checkbox" name="ac" value="1" id="t_account$round"$ck4><label for="t_account$round">�A�J�E���g</label>\n);

	# �Ǘ��җp
	if(Mebius::Admin::admin_mode_judge()){
		$line .= qq(<input type="checkbox" name="wdage" value="1" id="t_ua"$checked_ua><label for="t_ua">�t�`</label>\n);
			if($my_admin->{'master_flag'}){
				$line .= qq(<input type="checkbox" name="wdhost" value="1" id="t_host"$checked_host> <label for="t_host">�z�X�g��</label>\n);
			}
	}

return($line);

}

1;
