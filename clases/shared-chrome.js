/* =====================================================================
   shared-chrome.js — inyecta el sidebar del curso, el botón de
   colapsar y el toggle de modo oscuro. Persiste ambos estados en
   localStorage por navegador. No depende de librerías externas.
   ===================================================================== */
(function(){
  var PAGES = [
    { href: 'clase1_mentalidad_analitica.html', label: 'Mentalidad Analítica' },
    { href: 'clase2_herramientas_analiticas_1.html', label: 'Herramientas Analíticas' },
    { href: 'clase3_limpieza_calidad_datos_5.html', label: 'Limpieza y Calidad de Datos' },
    { href: 'clase4_sql_criterio_negocio_5.html', label: 'SQL y Criterio de Negocio' },
    { href: 'clase5_visualizacion_graficacion_3.html', label: 'Visualización y Graficación' },
    { href: 'clase6_modelos_estadisticos_4.html', label: 'Modelos Estadísticos Aplicados' },
    { href: 'clase7_dashboards_sheets_1.html', label: 'Dashboards en Sheets' },
    { href: 'clase_pipeline_sql_mysql.html', label: 'El Pipeline de Datos: MySQL' },
    { href: 'clase_modelado_dashboard_insights.html', label: 'Modelado, Dashboard e Insights' },
    { href: '', label: 'Storytelling y Comunicación', next: true }
  ];
  var REPASO = [
    { href: 'repaso_clases1-3_1.html', label: 'Repaso Clases 1–3' }
  ];

  function currentFile(){
    var parts = location.pathname.split('/');
    return parts[parts.length - 1] || '';
  }

  function escapeHtml(s){
    return s.replace(/[&<>]/g, function(c){ return { '&':'&amp;', '<':'&lt;', '>':'&gt;' }[c]; });
  }

  function buildNav(items){
    var here = currentFile();
    return items.map(function(it){
      var isActive = !!it.href && it.href === here;
      var cls = 'cc-item' + (isActive ? ' cc-active' : '') + (it.next ? ' cc-next' : '');
      var badge = it.next ? ' <span class="cc-badge">próxima</span>' : '';
      var label = '<span class="cc-n">·</span> ' + escapeHtml(it.label) + badge;
      if (!it.href) return '<span class="' + cls + '" title="Aún no existe">' + label + '</span>';
      return '<a class="' + cls + '" href="' + it.href + '">' + label + '</a>';
    }).join('');
  }

  function injectSidebar(){
    var aside = document.createElement('aside');
    aside.id = 'cc-sidebar';
    aside.innerHTML =
      '<h3>Curso de Analítica de Datos: Industria Musical</h3>' +
      '<div class="cc-group">' + buildNav(PAGES) + '</div>' +
      '<div class="cc-group"><h3>Repaso</h3>' + buildNav(REPASO) + '</div>';
    document.body.appendChild(aside);

    var toggleBtn = document.createElement('button');
    toggleBtn.id = 'cc-toggle-btn';
    toggleBtn.type = 'button';
    toggleBtn.setAttribute('aria-label', 'Mostrar u ocultar el menú de clases');
    toggleBtn.textContent = '☰';
    document.body.appendChild(toggleBtn);

    var darkBtn = document.createElement('button');
    darkBtn.id = 'cc-dark-btn';
    darkBtn.type = 'button';
    darkBtn.setAttribute('aria-label', 'Cambiar entre modo claro y oscuro');
    document.body.appendChild(darkBtn);

    document.body.classList.add('cc-pushed');

    var collapsed = localStorage.getItem('cc-sidebar-collapsed') === '1';
    applyCollapsed(collapsed);
    toggleBtn.addEventListener('click', function(){
      collapsed = !collapsed;
      applyCollapsed(collapsed);
      localStorage.setItem('cc-sidebar-collapsed', collapsed ? '1' : '0');
    });
    function applyCollapsed(c){
      aside.classList.toggle('cc-collapsed', c);
      document.body.classList.toggle('cc-collapsed', c);
      toggleBtn.classList.toggle('cc-collapsed', c);
    }

    var theme = localStorage.getItem('cc-theme') || 'light';
    applyTheme(theme);
    darkBtn.addEventListener('click', function(){
      theme = theme === 'dark' ? 'light' : 'dark';
      applyTheme(theme);
      localStorage.setItem('cc-theme', theme);
    });
    function applyTheme(t){
      document.documentElement.setAttribute('data-theme', t);
      document.documentElement.style.colorScheme = t;
      darkBtn.textContent = t === 'dark' ? '☀️' : '🌙';
    }
  }

  if (document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', injectSidebar);
  } else {
    injectSidebar();
  }
})();
