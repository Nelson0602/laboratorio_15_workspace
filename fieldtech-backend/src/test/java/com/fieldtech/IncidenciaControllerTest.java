package com.fieldtech;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.nullValue;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

// Pruebas de integracion del endpoint /api/v1/incidencias
@SpringBootTest
@AutoConfigureMockMvc
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
class IncidenciaControllerTest {

    @Autowired
    private MockMvc mockMvc;

    // Los datos iniciales de data.sql se cargan al arrancar
    @Test
    void listReturnsSeedData() throws Exception {
        mockMvc.perform(get("/api/v1/incidencias"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(3)))
                .andExpect(jsonPath("$[0].titulo").value("Poste con inclinación de riesgo"))
                .andExpect(jsonPath("$[0].tecnicoCodigo").value("TEC-001"));
    }

    // Un reporte con foto se guarda como REGISTRADA y con ruta de evidencia
    @Test
    void createWithPhotoReturnsCreated() throws Exception {
        MockMultipartFile photo = new MockMultipartFile(
                "foto", "poste.jpg", "image/jpeg", new byte[] {1, 2, 3});

        mockMvc.perform(multipart("/api/v1/incidencias")
                        .file(photo)
                        .param("titulo", "Cable caido")
                        .param("descripcion", "Cable de fibra en el suelo")
                        .param("categoria", "RED_ACCESO")
                        .param("latitud", "9.9322")
                        .param("longitud", "-84.0795")
                        .param("tecnicoCodigo", "TEC-CR-001"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(4))
                .andExpect(jsonPath("$.estado").value("REGISTRADA"))
                .andExpect(jsonPath("$.fotoUrl").value(startsWith("uploads/evidencias/")));

        mockMvc.perform(get("/api/v1/incidencias"))
                .andExpect(jsonPath("$", hasSize(4)));
    }

    // La foto es opcional
    @Test
    void createWithoutPhotoLeavesPhotoUrlEmpty() throws Exception {
        mockMvc.perform(multipart("/api/v1/incidencias")
                        .param("titulo", "Antena sin energia")
                        .param("descripcion", "Sin alimentacion electrica")
                        .param("categoria", "TORRE_RADIO")
                        .param("latitud", "9.84")
                        .param("longitud", "-83.86")
                        .param("tecnicoCodigo", "TEC-CR-001"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.fotoUrl").value(nullValue()));
    }
}
