<?php

namespace Tests\Feature;

use Tests\TestCase;

class VersionTest extends TestCase
{
    public function test_the_version_page_responds(): void
    {
        $this->get('/version')->assertOk();
    }
}
