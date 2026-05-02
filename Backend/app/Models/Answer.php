<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Answer extends Model
{
    protected $fillable = [
        'enrollment_id',
        'question_id',
        'question_option_id',
        'text_answer',
        'is_correct',
        'score',
    ];
}
