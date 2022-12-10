<?php

namespace App\Http\Controllers;

use Inertia\Inertia;

class FrontController extends Controller
{
    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function index()
    {
        return Inertia::render('Reservations/Index', []);
    }

}