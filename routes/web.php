<?php

use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;
use App\Http\Controllers\PostController;
use App\Http\Controllers\TableController;
use App\Http\Controllers\TableViewController;
use App\Http\Controllers\SuggestController;
use App\Http\Controllers\FrontController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return Inertia::render('Auth/Login', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});

Route::get('/dashboard', function () {
    return Inertia::render('Dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

require __DIR__.'/auth.php';



Route::resource('front', FrontController::class);
Route::resource('posts', PostController::class);
Route::resource('tables', TableController::class);
Route::resource('tableViews', TableViewController::class);
Route::resource('suggests', SuggestController::class);

Route::post('getTable', [TableController::class, 'getTable']);
Route::get('getRest', [TableController::class, 'getRest']);
Route::post('createTable', [TableController::class, 'createTable']);
Route::post('createRest', [TableController::class, 'createRest']);
Route::post('updateRest', [TableController::class, 'updateRest']);
Route::post('updateTable', [TableController::class, 'updateTable']);
Route::post('delRest', [TableController::class, 'delRest']);
Route::post('delTable', [TableController::class, 'delTable']);
Route::post('updateStatusById', [TableController::class, 'updateStatusById']);
Route::post('getTableByRestIdTableNo', [TableController::class, 'getTableByRestIdTableNo']);
Route::get('getSuggest', [SuggestController::class, 'getSuggest']);
Route::post('getTableById', [SuggestController::class, 'getTableById']);
Route::post('updateStatus', [SuggestController::class, 'updateStatus']);
Route::post('getSuggestByTableId', [SuggestController::class, 'getSuggestByTableId']);
Route::post('productSuggest', [SuggestController::class, 'productSuggest']);