<?php

use App\Http\Controllers\CertificateVerificationController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/certificates/verify/{code}', [CertificateVerificationController::class, 'show'])
    ->where('code', '.+')
    ->middleware('throttle:60,1');
