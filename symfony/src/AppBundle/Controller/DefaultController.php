<?php

namespace AppBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class DefaultController extends Controller
{
    /**
     * @Route("/", name="homepage")
     */
    public function indexAction(Request $request)
    {

        $pdo = $this->getDoctrine()->getConnection()->getWrappedConnection();
        $version = $pdo->query('select version()')->fetchColumn();
        // replace this example code with whatever you need
        return $this->render('default/index.html.twig', [
            'phpversion' => phpversion(),
            'mysqlversion' => $version,
            'base_dir' => realpath($this->getParameter('kernel.root_dir').'/..').DIRECTORY_SEPARATOR,
        ]);
    }
}
