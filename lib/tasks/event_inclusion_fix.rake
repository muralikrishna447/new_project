task :fix_event_inclusions => :environment do
  fix = [
    [2401, 240],
    [2402, 46],
    [2403, 47],
    [2404, 48],
    [2405, 241],
    [2406, 52],
    [2407, 26],
    [2408, 53],
    [2409, 14],
    [2410, 242],
    [2411, 41],
    [2412, 40],
    [2413, 42],
    [2414, 49],
    [2415, 243],
    [2416, 50],
    [2417, 60],
    [2418, 135],
    [3637, 364],
    [3638, 307],
    [3639, 318],
    [3640, 319],
    [3641, 249],
    [3642, 365],
    [3643, 311],
    [3644, 239],
    [3645, 366],
    [3646, 317],
    [3647, 246],
    [3648, 247],
    [3649, 367],
    [3650, 316],
    [3651, 300],
    [3652, 301],
    [3653, 260],
    [3835, 364],
    [3836, 307],
    [3837, 318],
    [3838, 319],
    [3839, 249],
    [3840, 365],
    [3841, 311],
    [3842, 239],
    [3843, 366],
    [3844, 317],
    [3845, 246],
    [3846, 247],
    [3847, 367],
    [3848, 316],
    [3849, 300],
    [3850, 301],
    [3851, 260],
    [3654, 61],
    [3655, 15],
    [3656, 27],
    [3657, 28],
    [3658, 17],
    [3659, 51],
    [3660, 35],
    [3661, 54],
    [3662, 110],
    [3663, 62],
    [3664, 46],
    [3665, 47],
    [3666, 48],
    [3667, 52],
    [3668, 26],
    [3669, 53],
    [3670, 50],
    [3671, 60],
    [3672, 135],
    [3673, 65],
    [3674, 58],
    [3675, 116],
    [3676, 130],
    [3677, 181],
    [3678, 67],
    [3679, 68],
    [3680, 193],
    [3681, 457],
    [3682, 70],
    [3683, 186],
    [3684, 177],
    [3685, 72],
    [3686, 129],
    [3687, 73],
    [3688, 6],
    [3689, 80],
    [3690, 81],
    [3691, 84],
    [3692, 85],
    [3693, 29],
    [3694, 75],
    [3695, 76],
    [3696, 77],
    [3697, 78],
    [3698, 79],
    [3699, 86],
    [3700, 10],
    [3701, 12],
    [3702, 23],
    [3703, 87],
    [3704, 88],
    [3705, 89],
    [3706, 90],
    [3707, 92],
    [3708, 7],
    [3709, 93],
    [3710, 1],
    [3711, 34],
    [3712, 118],
    [3713, 56],
    [3714, 94],
    [3715, 9],
    [3716, 117],
    [3717, 55],
    [3718, 13],
    [3719, 14],
    [3762, 61],
    [3763, 15],
    [3764, 27],
    [3765, 28],
    [3766, 51],
    [3767, 35],
    [3768, 54],
    [3769, 110],
    [3770, 62],
    [3771, 46],
    [3772, 47],
    [3773, 48],
    [3774, 52],
    [3775, 26],
    [3776, 53],
    [3777, 50],
    [3778, 60],
    [3779, 135],
    [3780, 65],
    [3781, 58],
    [3782, 116],
    [3783, 130],
    [3784, 181],
    [3785, 67],
    [3786, 68],
    [3787, 193],
    [3788, 457],
    [3789, 70],
    [3790, 186],
    [3791, 177],
    [3792, 72],
    [3793, 129],
    [3794, 73],
    [3795, 6],
    [3796, 80],
    [3797, 81],
    [3798, 84],
    [3799, 85],
    [3800, 29],
    [3801, 17],
    [3802, 75],
    [3803, 76],
    [3804, 86],
    [3805, 10],
    [3806, 12],
    [3807, 23],
    [3808, 87],
    [3809, 88],
    [3810, 89],
    [3811, 90],
    [3812, 92],
    [3813, 7],
    [3814, 93],
    [3815, 1],
    [3816, 34],
    [3817, 118],
    [3818, 56],
    [3819, 94],
    [3820, 9],
    [3821, 117],
    [3822, 55],
    [3823, 13],
    [3824, 14],
    [3720, 265],
    [3721, 41],
    [3722, 40],
    [3723, 488],
    [3724, 266],
    [3725, 42],
    [3726, 49],
    [3727, 513],
    [3728, 512],
    [3729, 269],
    [3852, 265],
    [3853, 41],
    [3854, 40],
    [3855, 488],
    [3856, 266],
    [3857, 42],
    [3858, 49],
    [3859, 513],
    [3860, 512],
    [3861, 269],
    [3746, 418],
    [3747, 282],
    [3748, 277],
    [3749, 416],
    [3750, 272],
    [3751, 273],
    [3752, 280],
    [3753, 361],
    [3754, 292],
    [3755, 417],
    [3756, 284],
    [3757, 281],
    [3758, 294],
    [3759, 381],
    [3760, 414],
    [3761, 395],
    [3862, 418],
    [3863, 282],
    [3864, 277],
    [3865, 416],
    [3866, 272],
    [3867, 273],
    [3868, 280],
    [3869, 361],
    [3870, 292],
    [3871, 417],
    [3872, 284],
    [3873, 281],
    [3874, 294],
    [3875, 381],
    [3876, 414],
    [3877, 395]
  ]

  # fix = {
  #   2401 => 240,
  #   2402 => 46,
  #   2403 => 47,
  #   2404 => 48,
  #   2405 => 241,
  #   2406 => 52,
  #   2407 => 26,
  #   2408 => 53,
  #   2409 => 14,
  #   2410 => 242,
  #   2411 => 41,
  #   2412 => 40,
  #   2413 => 42,
  #   2414 => 49,
  #   2415 => 243,
  #   2416 => 50,
  #   2417 => 60,
  #   2418 => 135,
  #   3637 => 364,
  #   3638 => 307,
  #   3639 => 318,
  #   3640 => 319,
  #   3641 => 249,
  #   3642 => 365,
  #   3643 => 311,
  #   3644 => 239,
  #   3645 => 366,
  #   3646 => 317,
  #   3647 => 246,
  #   3648 => 247,
  #   3649 => 367,
  #   3650 => 316,
  #   3651 => 300,
  #   3652 => 301,
  #   3653 => 260,
  #   3835 => 364,
  #   3836 => 307,
  #   3837 => 318,
  #   3838 => 319,
  #   3839 => 249,
  #   3840 => 365,
  #   3841 => 311,
  #   3842 => 239,
  #   3843 => 366,
  #   3844 => 317,
  #   3845 => 246,
  #   3846 => 247,
  #   3847 => 367,
  #   3848 => 316,
  #   3849 => 300,
  #   3850 => 301,
  #   3851 => 260,
  #   3654 => 61,
  #   3655 => 15,
  #   3656 => 27,
  #   3657 => 28,
  #   3658 => 17,
  #   3659 => 51,
  #   3660 => 35,
  #   3661 => 54,
  #   3662 => 110,
  #   3663 => 62,
  #   3664 => 46,
  #   3665 => 47,
  #   3666 => 48,
  #   3667 => 52,
  #   3668 => 26,
  #   3669 => 53,
  #   3670 => 50,
  #   3671 => 60,
  #   3672 => 135,
  #   3673 => 65,
  #   3674 => 58,
  #   3675 => 116,
  #   3676 => 130,
  #   3677 => 181,
  #   3678 => 67,
  #   3679 => 68,
  #   3680 => 193,
  #   3681 => 457,
  #   3682 => 70,
  #   3683 => 186,
  #   3684 => 177,
  #   3685 => 72,
  #   3686 => 129,
  #   3687 => 73,
  #   3688 => 6,
  #   3689 => 80,
  #   3690 => 81,
  #   3691 => 84,
  #   3692 => 85,
  #   3693 => 29,
  #   3694 => 75,
  #   3695 => 76,
  #   3696 => 77,
  #   3697 => 78,
  #   3698 => 79,
  #   3699 => 86,
  #   3700 => 10,
  #   3701 => 12,
  #   3702 => 23,
  #   3703 => 87,
  #   3704 => 88,
  #   3705 => 89,
  #   3706 => 90,
  #   3707 => 92,
  #   3708 => 7,
  #   3709 => 93,
  #   3710 => 1,
  #   3711 => 34,
  #   3712 => 118,
  #   3713 => 56,
  #   3714 => 94,
  #   3715 => 9,
  #   3716 => 117,
  #   3717 => 55,
  #   3718 => 13,
  #   3719 => 14,
  #   3762 => 61,
  #   3763 => 15,
  #   3764 => 27,
  #   3765 => 28,
  #   3766 => 51,
  #   3767 => 35,
  #   3768 => 54,
  #   3769 => 110,
  #   3770 => 62,
  #   3771 => 46,
  #   3772 => 47,
  #   3773 => 48,
  #   3774 => 52,
  #   3775 => 26,
  #   3776 => 53,
  #   3777 => 50,
  #   3778 => 60,
  #   3779 => 135,
  #   3780 => 65,
  #   3781 => 58,
  #   3782 => 116,
  #   3783 => 130,
  #   3784 => 181,
  #   3785 => 67,
  #   3786 => 68,
  #   3787 => 193,
  #   3788 => 457,
  #   3789 => 70,
  #   3790 => 186,
  #   3791 => 177,
  #   3792 => 72,
  #   3793 => 129,
  #   3794 => 73,
  #   3795 => 6,
  #   3796 => 80,
  #   3797 => 81,
  #   3798 => 84,
  #   3799 => 85,
  #   3800 => 29,
  #   3801 => 17,
  #   3802 => 75,
  #   3803 => 76,
  #   3804 => 86,
  #   3805 => 10,
  #   3806 => 12,
  #   3807 => 23,
  #   3808 => 87,
  #   3809 => 88,
  #   3810 => 89,
  #   3811 => 90,
  #   3812 => 92,
  #   3813 => 7,
  #   3814 => 93,
  #   3815 => 1,
  #   3816 => 34,
  #   3817 => 118,
  #   3818 => 56,
  #   3819 => 94,
  #   3820 => 9,
  #   3821 => 117,
  #   3822 => 55,
  #   3823 => 13,
  #   3824 => 14,
  #   3720 => 265,
  #   3721 => 41,
  #   3722 => 40,
  #   3723 => 488,
  #   3724 => 266,
  #   3725 => 42,
  #   3726 => 49,
  #   3727 => 513,
  #   3728 => 512,
  #   3729 => 269,
  #   3852 => 265,
  #   3853 => 41,
  #   3854 => 40,
  #   3855 => 488,
  #   3856 => 266,
  #   3857 => 42,
  #   3858 => 49,
  #   3859 => 513,
  #   3860 => 512,
  #   3861 => 269,
  #   3746 => 418,
  #   3747 => 282,
  #   3748 => 277,
  #   3749 => 416,
  #   3750 => 272,
  #   3751 => 273,
  #   3752 => 280,
  #   3753 => 361,
  #   3754 => 292,
  #   3755 => 417,
  #   3756 => 284,
  #   3757 => 281,
  #   3758 => 294,
  #   3759 => 381,
  #   3760 => 414,
  #   3761 => 395,
  #   3862 => 418,
  #   3863 => 282,
  #   3864 => 277,
  #   3865 => 416,
  #   3866 => 272,
  #   3867 => 273,
  #   3868 => 280,
  #   3869 => 361,
  #   3870 => 292,
  #   3871 => 417,
  #   3872 => 284,
  #   3873 => 281,
  #   3874 => 294,
  #   3875 => 381,
  #   3876 => 414,
  #   3877 => 395
  # }
  
  event_inclusions = Event.where(trackable_type: 'Inclusion')

  fix.each do |fix_array|
    inclusion_id = fix_array[0]
    activity_id = fix_array[1]
    puts "This is the inclusion_id #{inclusion_id}."
    puts "This is the activity_id #{activity_id}."
    fixable_events = event_inclusions.where(trackable_id: inclusion_id)
    puts "Fixing this many events #{fixable_events.count}"
    fixable_events.each do |event|
      puts "Changing from:"
      puts event.inspect
      puts "Changing to:"
      event.trackable_type = 'Activity'
      event.trackable_id = activity_id
      event.group_type = event.determine_group_type
      event.group_name = event.determine_group_name
      puts event.inspect
      if event.save
        puts "Successfully Saved event"
        puts event.inspect
        puts "Here's the activity to prove it:"
        puts event.trackable
      else
        puts "ERROR WHEN SAVING!!!!!!!!"
      end
    end
  end
end